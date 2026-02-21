#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/apps/magento-devops}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

echo "[bootstrap] Ensure Docker is installed and running before deploy"
