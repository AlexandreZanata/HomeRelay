#!/usr/bin/env bash
# HomeRelay — enable xrdp for remote desktop via SSH tunnel (homerelay-desktop)
# Usage: bash src/infra/setup-remote-desktop.sh
# Access: ssh -N homerelay-desktop → Remmina → localhost:3389
set -euo pipefail

echo "==> Installing xrdp..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y xrdp

echo "==> Enabling xrdp..."
sudo systemctl enable --now xrdp

# Allow RDP only from WireGuard subnet (optional extra hardening)
if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow from 10.8.0.0/24 to any port 3389 comment 'xrdp via VPN'
fi

echo "==> Done."
echo "On admin machine:"
echo "  ssh -N homerelay-desktop"
echo "  Remmina → RDP → localhost:3389 → Linux user + password"
