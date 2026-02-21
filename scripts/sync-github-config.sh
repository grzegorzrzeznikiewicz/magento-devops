#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   REPO=grzegorzrzeznikiewicz/magento-devops ./scripts/sync-github-config.sh ./github.env
# github.env should contain KEY=VALUE lines for required secrets and vars.

if [ "$#" -ne 1 ]; then
  echo "Usage: REPO=owner/repo $0 <env-file>"
  exit 1
fi

if [ -z "${REPO:-}" ]; then
  echo "Missing REPO env var (owner/repo)"
  exit 1
fi

ENV_FILE="$1"
if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

required_secrets=(
  VM1_HOST VM1_USER VM1_PASSWORD VM1_PORT GHCR_PAT
  COMPOSER_PUBLIC_KEY COMPOSER_PRIVATE_KEY
  MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD
  REDIS_PASSWORD OPENSEARCH_INITIAL_ADMIN_PASSWORD
  MAGENTO_ADMIN_USER MAGENTO_ADMIN_PASSWORD MAGENTO_ADMIN_EMAIL
)

required_vars=(
  MAGENTO_VERSION MAGENTO_BASE_URL MAGENTO_BACKEND_FRONTNAME
  MAGENTO_ADMIN_FIRSTNAME MAGENTO_ADMIN_LASTNAME
)

for key in "${required_secrets[@]}"; do
  val="${!key:-}"
  if [ -z "$val" ]; then
    echo "Missing secret value: $key"
    exit 1
  fi
  gh secret set "$key" --repo "$REPO" --body "$val"
  echo "Set secret: $key"
done

for key in "${required_vars[@]}"; do
  val="${!key:-}"
  if [ -z "$val" ]; then
    echo "Missing variable value: $key"
    exit 1
  fi
  gh variable set "$key" --repo "$REPO" --body "$val"
  echo "Set variable: $key"
done

echo "GitHub config sync completed for $REPO"
