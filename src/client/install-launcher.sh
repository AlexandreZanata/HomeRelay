#!/usr/bin/env bash
# Install HomeRelay desktop launcher on Pop!_OS / GNOME (admin machine)
# Usage: bash src/client/install-launcher.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_NAME="HomeRelay"
APP_ID="homerelay"
INSTALL_DIR="${HOME}/.local/share/homerelay"
DESKTOP_DIR="${HOME}/.local/share/applications"
USER_DESKTOP="${HOME}/Desktop"
ICON_SRC="${REPO_ROOT}/assets/homerelay-pc-icon.png"

mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$USER_DESKTOP"

install -m 755 "${REPO_ROOT}/src/client/connect-homerelay.sh" "${INSTALL_DIR}/connect-homerelay.sh"

if [[ ! -f "$ICON_SRC" ]]; then
  echo "Icon not found: $ICON_SRC" >&2
  exit 1
fi
cp "$ICON_SRC" "${INSTALL_DIR}/homerelay-pc-icon.png"

DESKTOP_FILE="${DESKTOP_DIR}/${APP_ID}.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Remote Home PC
Comment=SSH to home server via VPS (WireGuard)
Exec=${INSTALL_DIR}/connect-homerelay.sh
Icon=${INSTALL_DIR}/homerelay-pc-icon.png
Terminal=false
Categories=Network;RemoteAccess;
StartupNotify=true
Keywords=ssh;remote;homerelay;server;
EOF

chmod 644 "$DESKTOP_FILE"

# Desktop shortcut (one-click on workspace)
DESKTOP_SHORTCUT="${USER_DESKTOP}/${APP_ID}.desktop"
cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT"
chmod +x "$DESKTOP_SHORTCUT"
if command -v gio &>/dev/null; then
  gio set "$DESKTOP_SHORTCUT" metadata::trusted true 2>/dev/null || true
fi
cp "$ICON_SRC" "${USER_DESKTOP}/HomeRelay.png"

update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo "Installed:"
echo "  Script:   ${INSTALL_DIR}/connect-homerelay.sh"
echo "  Icon:     ${INSTALL_DIR}/homerelay-pc-icon.png"
echo "  Menu:     ${DESKTOP_FILE}"
echo "  Desktop:  ${DESKTOP_SHORTCUT}"
echo "  Icon PNG: ${USER_DESKTOP}/HomeRelay.png"
echo ""
echo "Double-click 'HomeRelay' on the desktop to SSH in one click."
echo "Test: ${INSTALL_DIR}/connect-homerelay.sh"
