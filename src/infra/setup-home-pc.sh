#!/usr/bin/env bash
# HomeRelay — Phase 1 home PC baseline (Ubuntu 24.04+)
# Usage: bash src/infra/setup-home-pc.sh
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run as normal user (script uses sudo internally)." >&2
  exit 1
fi

echo "==> Updating packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  openssh-server wireguard ufw network-manager curl ca-certificates

echo "==> Enabling SSH..."
sudo systemctl enable --now ssh

echo "==> Disabling sleep/suspend..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true

echo "==> Basic firewall (allow outbound; deny inbound by default)..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "==> Done. Verify:"
systemctl is-active ssh
sudo ufw status
echo "Next: docs/AGENT-RUNBOOK.md Phase 2 (VPS)"
