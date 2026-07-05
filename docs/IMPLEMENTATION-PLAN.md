# Implementation Plan

> Home PC as remote automation server — full architecture, installation, and operations reference.

**Open source:** every step uses free software. Works on **any PC**. To clone on another machine, start with [INSTALL-ON-ANOTHER-PC.md](INSTALL-ON-ANOTHER-PC.md).

**Agents:** execute [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) instead of improvising from this file.

---

## 1. Problem overview

Residential ISPs use **CGNAT** (shared public IP):

- You do **not** have a real public IP at home.
- Router port forwarding **does not work** for external access.
- The home PC cannot be reached directly from the internet.

**Solution:** the home PC **connects outbound** to a VPS, keeping a tunnel open. CGNAT does not block outbound connections. The VPS with a fixed public IP becomes the entry point.

---

## 2. Architecture

```
 [You — laptop/phone, anywhere]
              │  SSH
              ▼
 [VPS — fixed public IP]  ◄──── permanent WireGuard tunnel ────►  [Home PC — Wi-Fi]
   hub / entry point                                              no public IP, runs bots
```

### Components

| Component | Role |
|-----------|------|
| **WireGuard** | Private VPN; home PC gets internal IP (e.g. `10.8.0.2`) |
| **SSH** | Remote management; ProxyJump via VPS from anywhere |
| **PM2 / systemd** | 24/7 bots with auto-restart after crash or reboot |

---

## 3. Requirements

| Item | Specification |
|------|---------------|
| Home PC | Any x64 PC — e.g. i5 13th gen / 22 GB RAM or older hardware |
| Network | Home Wi-Fi (no Ethernet required) |
| VPS | 1 vCPU / 1–2 GB RAM |
| OS | Ubuntu 24.04 LTS (Desktop or Server) or Debian 12 |
| WhatsApp | **Dedicated** phone number for automations |

---

## Phase 1 — Home PC OS

**Recommended:** Ubuntu 24.04 LTS Desktop (Wi-Fi-friendly installer), hardened after install.

**Alternative:** Debian 12 firmware-netinst (minimal) or Ubuntu Server 24.04.

Post-install: [HOME-PC-SETUP.md](HOME-PC-SETUP.md).

---

## Phase 2 — VPS

See [VPS-SETUP.md](VPS-SETUP.md).

---

## Phase 3 — WireGuard

See [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) Phase 3.

Critical client setting: `PersistentKeepalive = 25`.

---

## Phase 4 — SSH remote access

Home PC SSH **only** via WireGuard — never expose port 22 to the internet.

ProxyJump example:

```
Host homerelay
    HostName 10.8.0.2
    User your_user
    ProxyJump your_user@VPS_PUBLIC_IP
```

---

## Phase 5 — Automations

Node.js via nvm; WhatsApp via Baileys (light) or whatsapp-web.js (heavier, fine on 22 GB RAM); scheduling via cron or n8n.

---

## Phase 6 — PM2

```bash
npm install -g pm2
pm2 start <bot> --name <name>
pm2 save && pm2 startup
```

---

## Phase 7 — Security

| Measure | Where |
|---------|-------|
| `ufw` | Home PC + VPS |
| `fail2ban` | VPS |
| `unattended-upgrades` | Both |
| Ed25519 SSH keys | All machines |
| No public SSH on home PC | Home PC |

---

## Phase 8 — Wi-Fi stability

Watchdog script: `src/infra/watchdog.sh` — cron every 5 minutes.

---

## Final test checklist

- [ ] `ping 10.8.0.2` works from VPS
- [ ] `ssh homerelay` works from outside home
- [ ] Reboot home PC → Wi-Fi, WireGuard, PM2 recover
- [ ] Wi-Fi off/on → watchdog reconnects within 5 min
- [ ] Power loss → PC boots automatically (BIOS)

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|--------------|-----|
| WireGuard won't connect | VPS firewall blocks UDP 51820 | `ufw status` + cloud security group |
| Wi-Fi won't reconnect on boot | `autoconnect` not set | `nmcli connection modify "<SSID>" connection.autoconnect yes` |
| WhatsApp bot disconnects | Session expired or ban | Reduce volume; re-scan QR |
| ProxyJump SSH fails | Tunnel down or keys missing | `ping 10.8.0.2` from VPS |
| PM2 missing after reboot | `pm2 startup` not applied | Re-run and apply systemd command |

---

## Legal notes

- Bulk WhatsApp without opt-in violates Meta ToS.
- Only recurring cost is typically the VPS.
- Technical guidance only — not legal advice.
