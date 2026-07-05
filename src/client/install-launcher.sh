#!/usr/bin/env bash
# Install HomeRelay GUI launcher (remote desktop) for Pop!_OS COSMIC
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_NAME="HomeRelay"
APP_ID="homerelay-desktop"
INSTALL_DIR="${HOME}/.local/share/homerelay"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
USER_DESKTOP="${HOME}/Desktop"
ICON_SRC="${REPO_ROOT}/assets/homerelay-pc-icon.png"

mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$USER_DESKTOP" "$BIN_DIR"

install -m 755 "${REPO_ROOT}/src/client/launch-desktop.sh" "${INSTALL_DIR}/launch-desktop.sh"
install -m 755 "${REPO_ROOT}/src/client/connect-homerelay.sh" "${INSTALL_DIR}/connect-homerelay.sh"
install -m 755 "${REPO_ROOT}/src/client/save-rdp-password.sh" "${INSTALL_DIR}/save-rdp-password.sh"
ln -sf "${INSTALL_DIR}/launch-desktop.sh" "${BIN_DIR}/homerelay-gui"
ln -sf "${INSTALL_DIR}/save-rdp-password.sh" "${BIN_DIR}/homerelay-save-password"

# Icons via pin-to-dock (hicolor)
bash "${REPO_ROOT}/src/client/pin-to-dock.sh"

DESKTOP_FILE="${DESKTOP_DIR}/${APP_ID}.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Remote Home Desktop
Comment=Full remote desktop to home PC via RDP + SSH tunnel
Exec=${BIN_DIR}/homerelay-gui
TryExec=${BIN_DIR}/homerelay-gui
Icon=homerelay
Terminal=false
DBusActivatable=false
StartupNotify=false
StartupWMClass=xfreerdp
Categories=Network;RemoteAccess;
Keywords=remote;desktop;rdp;homerelay;
EOF

chmod 644 "$DESKTOP_FILE"
cp "$DESKTOP_FILE" "${USER_DESKTOP}/${APP_ID}.desktop"
chmod +x "${USER_DESKTOP}/${APP_ID}.desktop"
command -v gio &>/dev/null && gio set "${USER_DESKTOP}/${APP_ID}.desktop" metadata::trusted true 2>/dev/null || true

update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# xfreerdp3 — Remmina 1.4.x cannot connect to Ubuntu 24.04 GNOME RDP (Graphics Pipeline)
if ! command -v xfreerdp3 &>/dev/null && ! command -v xfreerdp &>/dev/null; then
  echo "Installing xfreerdp3..."
  sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y freerdp3-x11
fi

echo ""
echo "Installed: ${BIN_DIR}/homerelay-gui  (fullscreen remote desktop)"
echo "Save password once: homerelay-save-password"
echo "SSH terminal only: ${INSTALL_DIR}/connect-homerelay.sh"
echo ""
echo "See docs/REMOTE-DESKTOP.md for full remote desktop setup."
