#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
DOCKER_CMD="${DOCKER_CMD:-docker}"
cd "$APP_DIR"

if [ ! -f .env ]; then
  echo "[install] Missing .env file"
  exit 1
fi

set -a
source .env
set +a
MAGENTO_PHP_MEMORY_LIMIT="${MAGENTO_PHP_MEMORY_LIMIT:-2G}"

echo "[install] Preparing writable Magento runtime directories..."
${DOCKER_CMD} exec -u 0 magento_php bash -lc "cd /var/www/html && mkdir -p var/cache var/page_cache generated pub/static pub/media app/etc && chown -R www-data:www-data var generated pub/static pub/media app/etc"

echo "[install] Installing PHP dependencies (composer install)..."
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && composer install --no-interaction --prefer-dist"

echo "[install] Waiting for MariaDB..."
until ${DOCKER_CMD} exec magento_db mariadb-admin ping -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent >/dev/null 2>&1; do
  sleep 5
done

echo "[install] Waiting for OpenSearch..."
until ${DOCKER_CMD} logs magento_opensearch 2>&1 | grep -qi "started"; do
  sleep 5
done

if ${DOCKER_CMD} exec magento_php test -f /var/www/html/app/etc/env.php; then
  echo "[install] Magento already installed, skipping setup:install"
  exit 0
fi

echo "[install] Running Magento setup:install"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:install \
  --base-url='${MAGENTO_BASE_URL}' \
  --db-host='mariadb' \
  --db-name='${MYSQL_DATABASE}' \
  --db-user='${MYSQL_USER}' \
  --db-password='${MYSQL_PASSWORD}' \
  --backend-frontname='${MAGENTO_BACKEND_FRONTNAME:-admin}' \
  --admin-firstname='${MAGENTO_ADMIN_FIRSTNAME:-Admin}' \
  --admin-lastname='${MAGENTO_ADMIN_LASTNAME:-User}' \
  --admin-email='${MAGENTO_ADMIN_EMAIL}' \
  --admin-user='${MAGENTO_ADMIN_USER}' \
  --admin-password='${MAGENTO_ADMIN_PASSWORD}' \
  --language='en_US' \
  --currency='USD' \
  --timezone='UTC' \
  --use-rewrites='1' \
  --search-engine='opensearch' \
  --opensearch-host='opensearch' \
  --opensearch-port='9200' \
  --opensearch-index-prefix='magento'"

echo "[install] Enabling production mode"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento deploy:mode:set production -s"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:static-content:deploy -f en_US"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento cache:flush"
${DOCKER_CMD} exec -u 0 magento_php bash -lc "cd /var/www/html && chown -R www-data:www-data var generated pub/static pub/media app/etc"
