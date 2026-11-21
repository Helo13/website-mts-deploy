#!/usr/bin/env bash
# rollback.sh - rollback website to the previous release on Hostinger.
#
# Prerequisite:
#   - Copy `previous_release/` (created by backup.sh) to the public_html folder.
#   - Run this script from the project root that contains previous_release/.

set -euo pipefail

PREV_DIR="previous_release"
TIMEOUT="5m"

if [[ ! -d "$PREV_DIR" ]]; then
  echo "[-] previous_release/ not found."
  echo "    Run backup.sh first to create a release snapshot."
  exit 1
fi

# SCP the snapshot to Hostinger
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
  "deploy@$(hostname 2>/dev/null || echo mtsmusixga.sch.id)" <<EOF
  rm -rf public_html/*
  cp -r "$PREV_DIR"/. public_html/
EOF

echo "[+] Stopped web server"
# Not needed if using Docker

echo "[+] Restarting web server"
# Replace with your web server restart command (systemctl, docker-compose, etc.)
# sudo systemctl reload nginx

echo "[+] Rollback finished: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
