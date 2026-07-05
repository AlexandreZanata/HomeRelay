# Admin Client Setup (Pop!_OS / laptop)

> Access the **home PC from any network** via VPS + WireGuard + SSH ProxyJump.
> Run these steps on your **admin machine** (e.g. Pop!_OS laptop) — not on the home PC.

Replace placeholders with values from your `.env` (never commit real IPs or keys).

---

## Prerequisites

- WireGuard tunnel active (home PC `10.8.0.2` ↔ VPS `10.8.0.1`)
- SSH on VPS reachable from the internet
- Home PC user created (e.g. `zanata-servidor`)

---

## Step 1 — SSH key on admin machine

### Option A — same key as home PC (simpler)

On **home PC**, copy securely to admin machine (USB, local `scp`, etc.):

```bash
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

On **admin machine**:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Option B — new key only on admin machine (recommended)

On **admin machine**:

```bash
ssh-keygen -t ed25519 -C "admin-homerelay"
```

Copy public key to **home PC**:

```bash
ssh-copy-id -o ProxyJump=${VPS_USER}@${VPS_PUBLIC_IP} ${HOME_PC_USER}@${HOME_PC_VPN_IP}
```

Or manually on home PC:

```bash
echo "PASTE_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Copy public key to **VPS**:

```bash
ssh-copy-id ${VPS_USER}@${VPS_PUBLIC_IP}
```

---

## Step 2 — `~/.ssh/config` on admin machine

Copy the template and fill in values:

```bash
cp src/infra/ssh-config.template ~/.ssh/config
chmod 600 ~/.ssh/config
# Edit: VPS_PUBLIC_IP, VPS_USER, HOME_PC_USER, HOME_PC_VPN_IP
```

Or paste manually:

```
Host homerelay-vps
    HostName <VPS_PUBLIC_IP>
    User <VPS_USER>
    IdentityFile ~/.ssh/id_ed25519

Host homerelay
    HostName <HOME_PC_VPN_IP>
    User <HOME_PC_USER>
    ProxyJump homerelay-vps
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host homerelay-desktop
    HostName <HOME_PC_VPN_IP>
    User <HOME_PC_USER>
    ProxyJump homerelay-vps
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 3389 127.0.0.1:3389
    ServerAliveInterval 60
```

---

## Step 3 — Test from another network

Use 4G/hotspot or Wi-Fi **outside** your home network:

```bash
ssh homerelay
```

Quick check:

```bash
ssh homerelay 'hostname && uptime'
```

---

## Step 4 — Terminal and file transfer

```bash
# interactive shell
ssh homerelay

# copy to home PC
scp document.pdf homerelay:~/

# copy from home PC
scp homerelay:~/document.pdf ~/Downloads/

# sync folder
rsync -avz homerelay:~/project/ ~/project/
```

---

## Step 5 — Remote desktop (optional)

**On home PC** (Ubuntu Desktop):

```bash
cd ~/Documents/HomeRelay   # or your clone path
bash src/infra/setup-remote-desktop.sh
```

**On admin machine (Pop!_OS):**

```bash
sudo apt update && sudo apt install -y remmina remmina-plugin-rdp

# keep this terminal open (tunnel)
ssh -N homerelay-desktop
```

Open **Remmina**:

| Field | Value |
|-------|--------|
| Protocol | RDP |
| Server | `localhost` |
| Port | `3389` |
| User | your Linux username |
| Password | your Linux password |

---

## Step 6 — Cursor / VS Code on admin machine

1. Install **Cursor** or **VS Code** on Pop!_OS
2. Install extension **Remote - SSH**
3. `Ctrl+Shift+P` → **Remote-SSH: Connect to Host** → `homerelay`
4. Open folder `~/Documents/HomeRelay` on the remote home PC

You edit and run code **on the home PC** as if you were sitting there.

---

## Optional desktop shortcut (Pop!_OS)

**One-click launcher (retro PC icon):**

```bash
cd ~/Documents/HomeRelay   # or your clone path
bash src/client/install-launcher.sh
```

Then open **HomeRelay** from the app menu or pin to the dock. It runs `ssh homerelay` in a terminal automatically.

Files installed to `~/.local/share/homerelay/` and `~/.local/share/applications/homerelay.desktop`.

Manual `.desktop` (alternative):

```ini
[Desktop Entry]
Name=HomeRelay SSH
Comment=Remote access to home server
Exec=gnome-terminal -- ssh homerelay
Icon=network-server
Type=Application
Terminal=false
```

---

## Troubleshooting

```bash
# 1. VPS reachable?
ping -c 2 <VPS_PUBLIC_IP>

# 2. SSH to VPS?
ssh homerelay-vps 'echo VPS_OK'

# 3. WireGuard tunnel up?
ssh homerelay-vps 'ping -c 2 <HOME_PC_VPN_IP>'

# 4. Verbose debug
ssh -v homerelay
```

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `homerelay` | Home PC off or WireGuard down |
| `Permission denied` | Key not in `authorized_keys` |
| VPS OK, home fails | Home Wi-Fi dropped — watchdog reconnects in ~5 min |

---

## Summary

On the admin machine you need:

1. `~/.ssh/id_ed25519` (or ed25519 key)
2. `~/.ssh/config` with `homerelay` + ProxyJump
3. `ssh homerelay` from anywhere

→ Next: [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) Phases 5–8 (bots, PM2, watchdog)
