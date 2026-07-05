#!/usr/bin/env bash
# HomeRelay — one-click SSH (Pop!_OS COSMIC)
set -euo pipefail

SSH_HOST="${HOMERELAY_SSH_HOST:-homerelay}"
DIR="${HOME}/.local/share/homerelay"
SESSION="${DIR}/ssh-session.sh"
LOG="${DIR}/launch.log"

mkdir -p "$DIR"
echo "$(date -Iseconds) launch" >> "$LOG"

if ! grep -qE "^Host[[:space:]]+${SSH_HOST}([[:space:]]|$)" "${HOME}/.ssh/config" 2>/dev/null; then
  notify-send "HomeRelay" "Missing SSH config for Host ${SSH_HOST}" -u critical 2>/dev/null || true
  echo "missing ssh config" >> "$LOG"
  exit 1
fi

cat > "$SESSION" <<SCRIPT
#!/usr/bin/env bash
ssh ${SSH_HOST}
echo
read -rp "Press Enter to close..."
SCRIPT
chmod +x "$SESSION"

if ! command -v cosmic-term &>/dev/null; then
  notify-send "HomeRelay" "cosmic-term not found" -u critical 2>/dev/null || true
  exit 1
fi

echo "$(date -Iseconds) exec cosmic-term" >> "$LOG"
exec cosmic-term bash "$SESSION"
