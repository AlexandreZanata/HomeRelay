#!/usr/bin/env bash
# Save RDP password locally (chmod 600) — one-time setup for one-click launch
set -euo pipefail

DIR="${HOME}/.local/share/homerelay"
PASSFILE="${DIR}/rdp-password"

mkdir -p "$DIR"
chmod 700 "$DIR"

if [[ -n "${1:-}" ]]; then
  printf '%s' "$1" >"$PASSFILE"
else
  if command -v zenity &>/dev/null; then
    zenity --password --title="HomeRelay" \
      --text="Home PC password (saved locally for one-click access):" >"$PASSFILE" || exit 1
  else
    read -rsp "Home PC password: " _pass
    echo
    printf '%s' "$_pass" >"$PASSFILE"
  fi
fi

chmod 600 "$PASSFILE"
echo "Password saved to ${PASSFILE} (never commit this file)."
echo "Click the HomeRelay dock icon or run: homerelay-gui"
