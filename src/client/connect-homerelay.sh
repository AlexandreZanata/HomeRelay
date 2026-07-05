#!/usr/bin/env bash
# HomeRelay — one-click SSH to home PC via ProxyJump
# Requires ~/.ssh/config with Host homerelay (see docs/ADMIN-CLIENT-SETUP.md)
set -euo pipefail

SSH_HOST="${HOMERELAY_SSH_HOST:-homerelay}"

# Quick preflight (non-blocking)
if ! grep -q "^Host[[:space:]]\+${SSH_HOST}\([[:space:]]\|$\)" ~/.ssh/config 2>/dev/null; then
  echo "Missing ~/.ssh/config entry for Host ${SSH_HOST}" >&2
  echo "See docs/ADMIN-CLIENT-SETUP.md" >&2
  read -r -p "Press Enter to exit..."
  exit 1
fi

open_terminal() {
  local cmd=(ssh "$SSH_HOST")
  if command -v gnome-terminal &>/dev/null; then
    exec gnome-terminal --title="HomeRelay" -- "${cmd[@]}"
  elif command -v kgx &>/dev/null; then
    exec kgx --title="HomeRelay" -- "${cmd[@]}"
  elif command -v x-terminal-emulator &>/dev/null; then
    exec x-terminal-emulator -t "HomeRelay" -e "${cmd[*]}"
  elif command -v konsole &>/dev/null; then
    exec konsole --new-tab -p tabtitle="HomeRelay" -e ssh "$SSH_HOST"
  else
    exec ssh "$SSH_HOST"
  fi
}

open_terminal
