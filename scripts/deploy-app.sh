#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
DOCKER_CMD="${DOCKER_CMD:-docker}"
cd "$APP_DIR"

if [ ! -f .env ]; then
  echo "[deploy] Missing .env file"
  exit 1
fi

set -a
source .env
set +a
MAGENTO_PHP_MEMORY_LIMIT="${MAGENTO_PHP_MEMORY_LIMIT:-2G}"

echo "[deploy] Preparing writable Magento runtime directories..."
${DOCKER_CMD} exec -u 0 magento_php bash -lc "cd /var/www/html && mkdir -p var/cache var/page_cache generated pub/static pub/media app/etc && chown -R www-data:www-data var generated pub/static pub/media app/etc"

echo "[deploy] Installing PHP dependencies (composer install)..."
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && composer install --no-dev --no-interaction --prefer-dist"

if ! ${DOCKER_CMD} exec magento_php test -f /var/www/html/app/etc/env.php; then
  echo "[deploy] Magento is not installed yet - running first install"
  DOCKER_CMD="${DOCKER_CMD}" APP_DIR="${APP_DIR}" ./scripts/install-magento.sh
  exit 0
fi

echo "[deploy] Running setup upgrade and build"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento maintenance:enable"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:upgrade --keep-generated"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:di:compile"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:static-content:deploy -f en_US"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento cache:flush"
${DOCKER_CMD} exec -u 0 magento_php bash -lc "cd /var/www/html && chown -R www-data:www-data var generated pub/static pub/media app/etc"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento maintenance:disable"

echo "[deploy] Done"
