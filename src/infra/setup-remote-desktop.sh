#!/usr/bin/env bash
# HomeRelay — enable GNOME Remote Desktop (RDP) on home PC
# Run ON THE HOME PC (or: ssh homerelay 'bash -s' < src/infra/setup-remote-desktop.sh)
set -euo pipefail

GRD_DIR="${HOME}/.local/share/gnome-remote-desktop"
CERT="${GRD_DIR}/tls.crt"
KEY="${GRD_DIR}/tls.key"

echo "==> Installing packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y gnome-remote-desktop

mkdir -p "$GRD_DIR"

if [[ ! -f "$CERT" || ! -f "$KEY" ]]; then
  echo "==> Generating RDP TLS certificate..."
  openssl req -x509 -nodes -newkey rsa:4096 -days 3650 \
    -keyout "$KEY" -out "$CERT" -subj "/CN=homerelay-local" 2>/dev/null
  chmod 600 "$KEY" "$CERT"
fi

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

echo "==> Configuring GNOME Remote Desktop..."
systemctl --user enable gnome-remote-desktop.service
systemctl --user start gnome-remote-desktop.service || true
sleep 2

grdctl rdp set-tls-cert "$CERT"
grdctl rdp set-tls-key "$KEY"
grdctl rdp enable
grdctl rdp disable-view-only
gsettings set org.gnome.desktop.remote-desktop.rdp enable true 2>/dev/null || true

RDP_USER="${RDP_USER:-${USER}}"
if [[ -z "${RDP_PASSWORD:-}" ]]; then
  echo ""
  read -rsp "RDP password for user ${RDP_USER} (used by xfreerdp3): " RDP_PASSWORD
  echo ""
fi
grdctl rdp set-credentials "$RDP_USER" "$RDP_PASSWORD"

echo ""
grdctl status
echo ""
echo "Done. On admin machine run: homerelay-save-password && homerelay-gui"
echo "See docs/REMOTE-DESKTOP.md for full setup."
