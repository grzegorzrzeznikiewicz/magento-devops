#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
DOCKER_CMD="${DOCKER_CMD:-docker}"
cd "$APP_DIR"

echo "[permissions] Normalizing Magento runtime ownership/perms..."
${DOCKER_CMD} exec -u 0 magento_php bash -lc "set -e; cd /var/www/html; \
  mkdir -p var/cache var/page_cache generated pub/static pub/media app/etc; \
  chown -R www-data:www-data var generated pub/static pub/media app/etc; \
  find var generated pub/static pub/media app/etc -type d -exec chmod 775 {} \;; \
  find var generated pub/static pub/media app/etc -type f -exec chmod 664 {} \;"

