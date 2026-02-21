#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
CRON_EXPR="${CRON_EXPR:-30 2 * * *}"

cat > /tmp/magento-backup.cron <<CRON
$CRON_EXPR cd $APP_DIR && /bin/bash -lc 'set -a; source .env; set +a; DOCKER_CMD=\"sudo docker\" RETENTION_DAYS=3 ./scripts/backup-mariadb.sh' >> /var/log/magento-backup.log 2>&1
CRON

crontab /tmp/magento-backup.cron
rm -f /tmp/magento-backup.cron

echo "[cron] Installed backup cron: $CRON_EXPR"
