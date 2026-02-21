#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/magento}"
RETENTION_DAYS="${RETENTION_DAYS:-3}"
TIMESTAMP="$(date +%F_%H-%M-%S)"
FILE="${BACKUP_DIR}/magento_db_${TIMESTAMP}.sql.gz"
DOCKER_CMD="${DOCKER_CMD:-docker}"

mkdir -p "$BACKUP_DIR"

${DOCKER_CMD} exec -i magento_db mysqldump -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" | gzip > "$FILE"

find "$BACKUP_DIR" -type f -name 'magento_db_*.sql.gz' -mtime +"${RETENTION_DAYS}" -delete

echo "Backup created: $FILE"
