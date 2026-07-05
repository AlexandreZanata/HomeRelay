# Install on Another PC

> **100% open source (MIT).** Clone and run on any PC — migrate, add a second machine, or let others self-host.

---

## Principles

| Principle | Practice |
|-----------|----------|
| **Open source** | MIT — no license fees |
| **No vendor lock-in** | WireGuard, PM2, Node.js — all free |
| **Reproducible** | Same repo + docs = same setup |
| **Local secrets** | Keys and tokens on disk only — never git |
| **Per-machine** | Each PC gets its own VPN IP and WireGuard keys |

---

## Clone

```bash
git clone --recurse-submodules https://github.com/AlexandreZanata/PC-ANTIGO-SERVIDOR.git
cd PC-ANTIGO-SERVIDOR
cp .env.example .env
```

Without submodule:

```bash
git submodule update --init --recursive
```

**Offline (USB):**

```bash
tar czf homerelay.tar.gz PC-ANTIGO-SERVIDOR/
# copy to USB → on target PC:
tar xzf homerelay.tar.gz && cd PC-ANTIGO-SERVIDOR
```

---

## Scenarios

### A — Migrate to new hardware

1. Clone repo on new PC.
2. Follow [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md) from Phase 1.
3. On VPS: replace WireGuard peer or add new peer.
4. Reconfigure `.env` and WhatsApp session.
5. Decommission old PC after [DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md) passes.

### B — Second PC in parallel

1. Use VPN IP `10.8.0.3` (or next free).
2. Add second `[Peer]` on VPS `wg0.conf`.
3. Separate WireGuard keys and WhatsApp session per PC.

---

## WireGuard — new PC on same VPS

**Replace old PC** (keep `10.8.0.2`):

```ini
[Peer]
PublicKey = <NEW_home_pc_public_key>
AllowedIPs = 10.8.0.2/32
```

**Additional PC:**

```ini
[Peer]
PublicKey = <second_pc_public_key>
AllowedIPs = 10.8.0.3/32
```

```bash
sudo systemctl restart wg-quick@wg0
```

---

## Update existing install

```bash
git pull
git submodule update --remote .agent-harness
pm2 restart all   # if bots running
```

Local `.env` and WireGuard configs are **not** overwritten by `git pull`.

---

## Open-source stack

| Tool | License | Role |
|------|---------|------|
| WireGuard | GPL v2 | VPN |
| OpenSSH | BSD | Remote access |
| PM2 | AGPL-3.0 | Process manager |
| Node.js | MIT | Bot runtime |
| Baileys | MIT | WhatsApp |
| Ubuntu | GPL | OS |

---

## References

- [README.md](../README.md)
- [AGENT-RUNBOOK.md](AGENT-RUNBOOK.md)
- [LICENSE](../LICENSE)
