# Agent Runbook

> **Primary execution guide for AI agents** setting up HomeRelay on the home PC via Cursor.
> Run phases in order. Verify each phase before continuing.

**Language:** English only. **Secrets:** never commit or echo in chat.

---

## Current assumed state

- [x] Ubuntu 24.04 LTS installed on home PC (Desktop is OK)
- [x] Repository cloned; Cursor open on home PC
- [ ] `.env` filled from `.env.example`
- [ ] All phases below completed

---

## Phase 0 — Gather configuration

**Agent action:** Ask the user for any blank values, then write `.env`:

```bash
cp -n .env.example .env
chmod 600 .env
```

Required variables (see `.env.example`):

| Variable | Description |
|----------|-------------|
| `VPS_PUBLIC_IP` | VPS public IPv4 |
| `VPS_USER` | SSH user on VPS |
| `HOME_PC_USER` | Linux user on this machine |
| `HOME_PC_VPN_IP` | Default `10.8.0.2` |
| `VPS_VPN_IP` | Default `10.8.0.1` |
| `WG_PORT` | Default `51820` |

**Verify:**

```bash
test -f .env && echo "OK: .env exists"
```

---

## Phase 1 — Home PC baseline

**Doc:** [HOME-PC-SETUP.md](HOME-PC-SETUP.md)

**Agent action:** Run the setup script (user will enter sudo password):

```bash
bash src/infra/setup-home-pc.sh
```

This installs: OpenSSH, WireGuard tools, ufw basics, disables sleep, enables SSH.

**Verify:**

```bash
systemctl is-active ssh
systemctl is-enabled ssh
nmcli networking connectivity check || ping -c1 8.8.8.8
```

---

## Phase 2 — VPS preparation

**Doc:** [VPS-SETUP.md](VPS-SETUP.md)

**Agent action:** SSH into VPS from home PC (user must have access):

```bash
ssh ${VPS_USER}@${VPS_PUBLIC_IP}
```

On VPS, run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ufw wireguard
sudo ufw allow OpenSSH
sudo ufw allow ${WG_PORT}/udp
sudo ufw --force enable
```

Also open UDP `${WG_PORT}` in the **cloud provider security group**.

**Verify (on VPS):**

```bash
sudo ufw status
which wg
```

---

## Phase 3 — WireGuard tunnel

### 3a — Generate keys on home PC

```bash
sudo mkdir -p /etc/wireguard
sudo chmod 700 /etc/wireguard
wg genkey | sudo tee /etc/wireguard/client_private.key | wg pubkey | sudo tee /etc/wireguard/client_public.key
sudo chmod 600 /etc/wireguard/client_private.key
```

Show the user **only the public key** (safe to share):

```bash
sudo cat /etc/wireguard/client_public.key
```

### 3b — Generate keys on VPS

On VPS:

```bash
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
sudo chmod 600 /etc/wireguard/server_private.key
```

### 3c — Configure VPS `/etc/wireguard/wg0.conf`

```ini
[Interface]
Address = ${VPS_VPN_IP}/24
ListenPort = ${WG_PORT}
PrivateKey = <server_private.key contents>

[Peer]
# Home PC
PublicKey = <client_public.key from home PC>
AllowedIPs = ${HOME_PC_VPN_IP}/32
```

### 3d — Configure home PC `/etc/wireguard/wg0.conf`

```ini
[Interface]
Address = ${HOME_PC_VPN_IP}/24
PrivateKey = <client_private.key contents>

[Peer]
PublicKey = <server_public.key from VPS>
Endpoint = ${VPS_PUBLIC_IP}:${WG_PORT}
AllowedIPs = ${VPS_VPN_IP}/24
PersistentKeepalive = 25
```

### 3e — Enable on both sides

```bash
sudo systemctl enable --now wg-quick@wg0
```

**Verify (from VPS):**

```bash
ping -c 3 ${HOME_PC_VPN_IP}
sudo wg show
```

---

## Phase 4 — Remote SSH access

### On home PC

```bash
sudo systemctl enable --now ssh
```

### On admin machine `~/.ssh/config`

```
Host homerelay
    HostName ${HOME_PC_VPN_IP}
    User ${HOME_PC_USER}
    ProxyJump ${VPS_USER}@${VPS_PUBLIC_IP}
```

### Harden SSH (both machines, after keys work)

In `/etc/ssh/sshd_config`:

```
PasswordAuthentication no
```

```bash
sudo systemctl restart sshd
```

**Verify (from outside home network):**

```bash
ssh homerelay hostname
```

---

## Phase 5 — Node.js runtime

On home PC:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
node -v && npm -v
```

---

## Phase 6 — PM2 and bots

```bash
npm install -g pm2
# When bots exist in src/bots/:
# pm2 start src/bots/whatsapp-bot.js --name whatsapp-bot
pm2 save
pm2 startup   # run the printed sudo command
```

**Verify:**

```bash
pm2 status
sudo reboot   # user confirms; after reboot:
pm2 status
```

---

## Phase 7 — Security

**Home PC:**

```bash
sudo apt install -y unattended-upgrades
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

**VPS:**

```bash
sudo apt install -y fail2ban unattended-upgrades
```

**Never** expose home PC port 22 to the public internet.

---

## Phase 8 — Wi-Fi watchdog

On home PC:

```bash
sudo bash src/infra/install-watchdog.sh
```

**Verify:** disconnect Wi-Fi briefly; within 5 minutes tunnel should recover.

---

## Phase 9 — Final validation

Check [DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md) phases 0–9.

| Test | Command | Expected |
|------|---------|----------|
| Tunnel | `ping ${HOME_PC_VPN_IP}` from VPS | replies |
| Remote SSH | `ssh homerelay` from outside | shell on home PC |
| Reboot | reboot home PC | Wi-Fi, WG, PM2 return |
| Watchdog | Wi-Fi off/on | reconnect ≤ 5 min |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| WireGuard down | Check VPS UDP port + `sudo wg show` |
| Wi-Fi drops | `nmcli connection modify "<SSID>" connection.autoconnect yes` |
| PM2 missing after reboot | Re-run `pm2 startup` and apply systemd command |
| SSH ProxyJump fails | Ping VPN IP from VPS first |

Full table: [IMPLEMENTATION-PLAN.md](IMPLEMENTATION-PLAN.md#troubleshooting).

---

## What agents must not do

- Commit `.env`, private keys, or WhatsApp session data
- Expose home PC SSH to `0.0.0.0/0`
- Skip verification between phases
- Assume VPS IP or credentials — always ask
