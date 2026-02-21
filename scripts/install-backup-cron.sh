#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
CRON_EXPR="${CRON_EXPR:-30 2 * * *}"
BLOCK_BEGIN="# BEGIN MAGENTO_DEVOPS"
BLOCK_END="# END MAGENTO_DEVOPS"

EXISTING_CRON="$(mktemp)"
NEW_CRON="$(mktemp)"
crontab -l > "$EXISTING_CRON" 2>/dev/null || true

awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  skip != 1 {print}
' "$EXISTING_CRON" > "$NEW_CRON"

cat >> "$NEW_CRON" <<CRON
$BLOCK_BEGIN
$CRON_EXPR cd $APP_DIR && /bin/bash -lc 'set -a; source .env; set +a; DOCKER_CMD="sudo docker" RETENTION_DAYS=3 ./scripts/backup-mariadb.sh' >> /var/log/magento-backup.log 2>&1
* * * * * cd $APP_DIR && /bin/bash -lc 'set -a; source .env; set +a; DOCKER_CMD="sudo docker" ./scripts/run-magento-cron.sh' >> /var/log/magento-cron.log 2>&1
$BLOCK_END
CRON

crontab "$NEW_CRON"
rm -f "$EXISTING_CRON" "$NEW_CRON"

echo "[cron] Installed backup and Magento cron jobs (backup: $CRON_EXPR)"
