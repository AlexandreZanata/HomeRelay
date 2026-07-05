#!/usr/bin/env bash
# HomeRelay Wi-Fi + WireGuard watchdog
# Pings VPS VPN IP; restarts tunnel and Wi-Fi radio if unreachable.
set -euo pipefail

VPS_VPN_IP="${VPS_VPN_IP:-10.8.0.1}"
LOG_TAG="homerelay-watchdog"

log() { logger -t "$LOG_TAG" "$*"; }

if ping -c 2 -W 5 "$VPS_VPN_IP" &>/dev/null; then
  exit 0
fi

log "Tunnel down — restarting WireGuard and Wi-Fi"
systemctl restart wg-quick@wg0 2>/dev/null || log "wg-quick@wg0 restart failed (not configured yet?)"

if command -v nmcli &>/dev/null; then
  nmcli radio wifi off
  sleep 3
  nmcli radio wifi on
fi

exit 0
