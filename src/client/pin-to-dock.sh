#!/usr/bin/env bash
# Install icons (hicolor) + pin HomeRelay to COSMIC dock
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL_DIR="${HOME}/.local/share/homerelay"
ICON_SRC="${REPO_ROOT}/assets/homerelay-pc-icon.png"
HICOLOR="${HOME}/.local/share/icons/hicolor"
FAVORITES="${HOME}/.config/cosmic/com.system76.CosmicAppList/v1/favorites"
APP_ID="homerelay-desktop"
OLD_APP_ID="homerelay"

[[ -f "$ICON_SRC" ]] || { echo "Missing $ICON_SRC" >&2; exit 1; }
mkdir -p "$INSTALL_DIR"

python3 - "$ICON_SRC" "$HICOLOR" "$INSTALL_DIR" <<'PY'
import sys
from pathlib import Path
from PIL import Image

src, hicolor, install_dir = sys.argv[1:4]
img = Image.open(src)
for size in (48, 64, 128, 256):
    d = Path(hicolor) / f"{size}x{size}" / "apps"
    d.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.Resampling.LANCZOS).save(d / "homerelay.png")
Path(install_dir).mkdir(parents=True, exist_ok=True)
img.resize((128, 128), Image.Resampling.LANCZOS).save(Path(install_dir) / "homerelay.png")
print("hicolor icons:", hicolor)
PY

gtk-update-icon-cache -f -t "${HICOLOR}" 2>/dev/null || true

for f in "${HOME}/.local/share/applications/${APP_ID}.desktop" "${HOME}/Desktop/${APP_ID}.desktop"; do
  [[ -f "$f" ]] || continue
  sed -i 's|^Icon=.*|Icon=homerelay|' "$f"
  sed -i 's|^Exec=.*|Exec='"${HOME}"'/.local/bin/homerelay-gui|' "$f"
  sed -i '/^StartupWMClass=/d' "$f"
  grep -q '^StartupNotify=' "$f" && sed -i 's|^StartupNotify=.*|StartupNotify=false|' "$f" || true
done

[[ -f "${HOME}/Desktop/${APP_ID}.desktop" ]] && chmod +x "${HOME}/Desktop/${APP_ID}.desktop"
command -v gio &>/dev/null && gio set "${HOME}/Desktop/${APP_ID}.desktop" metadata::trusted true 2>/dev/null || true
cp "${INSTALL_DIR}/homerelay.png" "${HOME}/Desktop/HomeRelay.png" 2>/dev/null || true

if [[ -f "$FAVORITES" ]]; then
  sed -i "/\"${OLD_APP_ID}\"/d" "$FAVORITES"
  if ! grep -q "\"${APP_ID}\"" "$FAVORITES" 2>/dev/null; then
    sed -i "0,/^\\[$/s//[\n    \"${APP_ID}\",/" "$FAVORITES"
  fi
fi

rm -f "${HOME}/.local/share/applications/${OLD_APP_ID}.desktop" \
      "${HOME}/Desktop/${OLD_APP_ID}.desktop" 2>/dev/null || true

update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
echo "Icons: hicolor theme 'homerelay'"
echo "Exec: ${HOME}/.local/bin/homerelay-gui"
