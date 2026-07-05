#!/usr/bin/env bash
# HomeRelay — keep home PC awake 24/7 (lid closed, no suspend)
# Run ON THE HOME PC (or: ssh homerelay 'bash -s' < src/infra/setup-server-awake.sh)
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run as normal user (script uses sudo internally)." >&2
  exit 1
fi

echo "==> Blocking systemd sleep/suspend/hibernate..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true

echo "==> Ignoring laptop lid close (stay on with lid shut)..."
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/50-homerelay-lid.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
HandlePowerKey=ignore
IdleAction=ignore
EOF
sudo systemctl restart systemd-logind

echo "==> GNOME power: never sleep, lid does nothing..."
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing' 2>/dev/null || true
gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false 2>/dev/null || true

echo "==> Wi-Fi: do not power-save (stay reachable lid closed)..."
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/99-homerelay-wifi.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF
sudo systemctl reload NetworkManager 2>/dev/null || true

echo ""
echo "Done. Home PC should stay online with lid closed."
echo ""
echo "BIOS (do manually on the laptop):"
echo "  - Wake on AC power loss / Power On after outage"
echo "  - Disable Deep Sleep / Modern Standby if available"
echo "  - Keep plugged into power 24/7"
echo ""
echo "Test: close lid, wait 2 min, from Pop!_OS run: ssh homerelay hostname"
