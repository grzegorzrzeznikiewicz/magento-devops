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
MAINTENANCE_ENABLED=0

cleanup() {
  if [ "$MAINTENANCE_ENABLED" -eq 1 ]; then
    ${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento maintenance:disable'" || true
  fi
}
trap cleanup EXIT

echo "[deploy] Preparing writable Magento runtime directories..."
./scripts/fix-runtime-permissions.sh

echo "[deploy] Installing PHP dependencies (composer install)..."
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && composer install --no-dev --no-interaction --prefer-dist"

if ! ${DOCKER_CMD} exec magento_php test -f /var/www/html/app/etc/env.php; then
  echo "[deploy] Magento is not installed yet - running first install"
  DOCKER_CMD="${DOCKER_CMD}" APP_DIR="${APP_DIR}" ./scripts/install-magento.sh
  exit 0
fi

echo "[deploy] Running setup upgrade and build"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento maintenance:enable'"
MAINTENANCE_ENABLED=1
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:upgrade --keep-generated'"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:di:compile'"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento setup:static-content:deploy -f en_US'"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento deploy:mode:set production -s'"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento cache:flush'"
./scripts/fix-runtime-permissions.sh
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento maintenance:disable'"
MAINTENANCE_ENABLED=0

echo "[deploy] Done"
