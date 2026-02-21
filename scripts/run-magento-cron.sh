#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
DOCKER_CMD="${DOCKER_CMD:-docker}"
MAGENTO_PHP_MEMORY_LIMIT="${MAGENTO_PHP_MEMORY_LIMIT:-2G}"
cd "$APP_DIR"

${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento cron:run'"
${DOCKER_CMD} exec magento_php bash -lc "cd /var/www/html && su -s /bin/sh www-data -c 'php -d memory_limit=${MAGENTO_PHP_MEMORY_LIMIT} bin/magento cron:run'"

