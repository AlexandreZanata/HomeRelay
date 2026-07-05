# Home PC Setup

> Phase 1 target: Ubuntu 24.04 LTS (Desktop) on the home PC — after OS install, before VPS/WireGuard.
> **Agent:** run `src/infra/setup-home-pc.sh` and verify below.

---

## Context

The home PC runs behind **CGNAT** on Wi-Fi. It will:

- Maintain an outbound **WireGuard** tunnel to the VPS
- Run automation bots 24/7 via **PM2**
- Stay awake (no suspend/hibernate)

Ubuntu **Desktop 24.04** is supported — harden it for server use below. GUI may remain; bots run headless.

---

## Automated setup

```bash
cd /path/to/PC-ANTIGO-SERVIDOR
bash src/infra/setup-home-pc.sh
```

---

## Manual steps (reference)

### OpenSSH server

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

### Disable sleep / suspend

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### Keep awake with lid closed (24/7 server)

```bash
bash src/infra/setup-server-awake.sh
```

Configures: ignore lid switch, GNOME never-sleep, Wi-Fi power-save off. See [REMOTE-DESKTOP.md](REMOTE-DESKTOP.md).

---

### Wi-Fi autoconnect on boot

If not already connected:

```bash
sudo apt install -y network-manager
nmcli device wifi list
sudo nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
sudo nmcli connection modify "YOUR_SSID" connection.autoconnect yes
```

### WireGuard tools (keys configured in Phase 3)

```bash
sudo apt install -y wireguard
```

### Optional — reduce desktop footprint (ask user first)

```bash
# Only if user wants a leaner system — may affect GUI login
# sudo apt remove --purge libreoffice-common thunderbird -y
# sudo apt autoremove -y
```

### Optional — boot to multi-user (no GUI)

Only if user explicitly wants headless operation:

```bash
# sudo systemctl set-default multi-user.target
# sudo systemctl disable gdm3
```

### BIOS (physical — remind user)

- Enable **Power On After Power Failure** / **Restore on AC Power Loss**
- Use a **UPS** if possible

---

## Verification

```bash
systemctl is-active ssh && echo "SSH: OK"
systemctl is-enabled ssh && echo "SSH enabled: OK"
ping -c 2 8.8.8.8 && echo "Internet: OK"
```

---

## Next phase

→ [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) Phase 2 — [VPS-SETUP.md](VPS-SETUP.md)
