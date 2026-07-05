# HomeRelay

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**100% open source** — turn any home PC into a 24/7 remote automation server reachable via a VPS, with no public IP and no port forwarding.

```
[You — laptop/phone] ──SSH──► [VPS — public IP] ◄──WireGuard──► [Home PC — Wi-Fi]
```

## What this project does

A home PC behind **CGNAT** (no real public IP) maintains an **outbound WireGuard tunnel** to a cheap VPS. The VPS is the entry point; you SSH into the home PC from anywhere. Automation bots (WhatsApp, scheduled posts) run locally on the home hardware.

## Quick start (home PC with Linux already installed)

```bash
git clone --recurse-submodules https://github.com/AlexandreZanata/PC-ANTIGO-SERVIDOR.git
cd PC-ANTIGO-SERVIDOR
cp .env.example .env   # fill in locally — never commit
```

**Open this repo in Cursor on the home PC**, then tell the agent:

> Follow `docs/AGENT-RUNBOOK.md` from Phase 1.

## Documentation

| Document | Purpose |
|----------|---------|
| [**AGENT-RUNBOOK**](docs/AGENT-RUNBOOK.md) | **Start here in Cursor** — phased setup for AI agents |
| [HOME-PC-SETUP](docs/HOME-PC-SETUP.md) | Post-install steps on the home PC (Ubuntu 24.04) |
| [VPS-SETUP](docs/VPS-SETUP.md) | VPS hub configuration |
| [IMPLEMENTATION-PLAN](docs/IMPLEMENTATION-PLAN.md) | Full architecture and reference |
| [DEPLOYMENT-CHECKLIST](docs/DEPLOYMENT-CHECKLIST.md) | Phase-by-phase validation |
| [INSTALL-ON-ANOTHER-PC](docs/INSTALL-ON-ANOTHER-PC.md) | Clone, migrate, second machine |
| [GLOSSARY](docs/GLOSSARY.md) | Domain terms |
| [Use cases](docs/use-cases/) | Operational flows |
| [AGENTS.md](AGENTS.md) | Agent entry point |

## Stack

| Component | Role |
|-----------|------|
| Ubuntu 24.04 LTS | Home PC OS (Desktop OK — hardened after install) |
| WireGuard | Private VPN Home PC ↔ VPS |
| SSH + ProxyJump | Secure remote access |
| PM2 | Always-on bots with auto-restart |
| Node.js (nvm) | Automation runtime |
| Baileys / whatsapp-web.js / n8n | WhatsApp and post scheduling |

## Open source guarantees

- **MIT license** — fork, modify, redistribute freely
- **No vendor lock-in** — WireGuard, OpenSSH, PM2, Node.js
- **Reproducible** — clone on any PC, follow the docs
- **Secrets stay local** — `.env`, WireGuard keys, tokens never in git
- **Only recurring cost** — your VPS (~€3–5/month or free tier)

## For AI agents

Read [AGENTS.md](AGENTS.md) first. Execute [docs/AGENT-RUNBOOK.md](docs/AGENT-RUNBOOK.md) phase by phase. Ask the user for missing values (VPS IP, usernames) — never assume or commit secrets.

## Legal notes

- Bulk WhatsApp without opt-in violates Meta ToS and may cause bans. Use a **dedicated number**.
- Technical guidance only — not legal advice on data or marketing.

## License

[MIT](LICENSE) — third-party notices in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
