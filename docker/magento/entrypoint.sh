#!/usr/bin/env bash
set -euo pipefail

if [ -n "${COMPOSER_PUBLIC_KEY:-}" ] && [ -n "${COMPOSER_PRIVATE_KEY:-}" ]; then
  composer config --global http-basic.repo.magento.com "${COMPOSER_PUBLIC_KEY}" "${COMPOSER_PRIVATE_KEY}" || true
fi

if [ ! -f /var/www/html/composer.json ]; then
  echo "[entrypoint] Initializing Magento ${MAGENTO_VERSION}"
  composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition:"${MAGENTO_VERSION}" /var/www/html
fi

exec "$@"
