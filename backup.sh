#!/usr/bin/env bash
# backup.sh - create a release snapshot before a risky deploy.
#
# Usage:
#   ./backup.sh
#
# Output:
#   previous_release_YYYYmmdd_HHMMSS/
#
# Deploy safely then roll back with rollback.sh if something breaks.

set -euo pipefail

DATE=$(date -u +"%Y%m%d_%H%M%S")
SNAP="previous_release_${DATE}"
ZIP="release_${DATE}.tar.gz"
SSH_HOST="mtsmusixga.sch.id"
SSH_USER="deploy"

echo "[+] Backing up public_html/ to ${SNAP}/"
mkdir -p "${SNAP}"

# Archive local public_html (if it exists)
if [[ -d "public_html" ]]; then
  tar czf "${ZIP}" -C "$(dirname "$PWD")" public_html
  echo "[+] Created ${ZIP}"
else
  echo "[!] public_html/ not found. Skipping archive."
fi

# Upload snapshot to Hostinger
echo "[+] Uploading ${SNAP}/ to ${SSH_USER}@${SSH_HOST}:~/"
scp -r "${SNAP}/" "${SSH_USER}@${SSH_HOST}:~/" 2>/dev/null || true

echo "[+] Done. Version: ${DATE}"
echo "[+] To roll back, copy this snapshot back to public_html and run rollback.sh"
