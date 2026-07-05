#!/usr/bin/env bash
# Install watchdog to /usr/local/bin and cron (every 5 min)
# Usage: sudo bash src/infra/install-watchdog.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/usr/local/bin/homerelay-watchdog.sh"

install -m 755 "$SCRIPT_DIR/watchdog.sh" "$DEST"

CRON_LINE="*/5 * * * * $DEST"
( crontab -l 2>/dev/null | grep -vF "$DEST"; echo "$CRON_LINE" ) | crontab -

echo "Installed: $DEST"
echo "Cron: $CRON_LINE"
crontab -l | grep homerelay
