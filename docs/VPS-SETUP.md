# VPS Setup

> Phase 2 target: prepare the cloud VPS as the WireGuard hub and SSH jump host.
> **Agent:** SSH from home PC (or ask user to run commands on VPS).

---

## Requirements

| Spec | Minimum |
|------|---------|
| vCPU | 1 |
| RAM | 1–2 GB |
| OS | Ubuntu 22.04/24.04 LTS or Debian 12 |
| Network | Public IPv4; UDP **51820** open (ufw + cloud firewall) |

Providers: Hetzner, Contabo, DigitalOcean, Oracle Free Tier, etc.

---

## Initial server setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ufw wireguard curl
```

Create a non-root user if needed:

```bash
sudo adduser deploy
sudo usermod -aG sudo deploy
```

---

## Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 51820/udp
sudo ufw --force enable
sudo ufw status verbose
```

**Cloud panel:** add inbound rule **UDP 51820** from `0.0.0.0/0` (or restrict to home ISP if known).

---

## WireGuard server (Phase 3)

Keys and `wg0.conf` are created in [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) Phase 3.

Server template (`/etc/wireguard/wg0.conf`):

```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <server_private.key>

[Peer]
# Home PC
PublicKey = <home_pc_public.key>
AllowedIPs = 10.8.0.2/32
```

```bash
sudo systemctl enable --now wg-quick@wg0
```

---

## SSH hardening (after key-based login works)

`/etc/ssh/sshd_config`:

```
PasswordAuthentication no
PermitRootLogin no
```

```bash
sudo systemctl restart sshd
```

---

## fail2ban (recommended)

```bash
sudo apt install -y fail2ban unattended-upgrades
sudo systemctl enable --now fail2ban
```

---

## Verification

```bash
sudo wg show
ping -c 3 10.8.0.2    # after home PC peer is configured
```

---

## Adding a second home PC

Add another `[Peer]` block with a new IP (e.g. `10.8.0.3/32`) and new public key.

See [INSTALL-ON-ANOTHER-PC.md](INSTALL-ON-ANOTHER-PC.md).

---

## Next phase

→ [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) Phase 3 — WireGuard tunnel
