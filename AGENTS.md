# AGENTS.md — HomeRelay

> **Read this first** in every Cursor session on the home PC or dev machine.

**Language:** 100% English — code, docs, comments, commits, and all agent output.

---

## What this repository is

| Is | Is not |
|----|--------|
| Open-source home automation server (MIT) | Closed SaaS or vendor lock-in |
| Agent-driven setup via `docs/AGENT-RUNBOOK.md` | A finished deploy-without-configuration app |
| WireGuard + SSH + PM2 + bots on a home PC | Bound to one machine or VPS |

**Goal:** home PC (no public IP, Wi-Fi) → 24/7 automation server reachable via VPS.

**You are likely on the home PC right now.** Execute the runbook locally unless the phase explicitly targets the VPS.

---

## Mandatory read order

1. [docs/AGENT-RUNBOOK.md](docs/AGENT-RUNBOOK.md) — **execute phase by phase**
2. [docs/DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md) — mark items as you complete them
3. [docs/GLOSSARY.md](docs/GLOSSARY.md) — use terms exactly as defined
4. [docs/IMPLEMENTATION-PLAN.md](docs/IMPLEMENTATION-PLAN.md) — architecture reference

When harness rules conflict with existing code, **rules prevail** unless the user explicitly overrides.

---

## Agent protocol (home PC setup)

### Before any command

1. Confirm you are on the **home PC** (`uname -a`, hostname).
2. Read `.env` if it exists — never print secrets in chat.
3. State which **runbook phase** you are executing.

### Ask the user if missing (never assume)

| Variable | Example | Used for |
|----------|---------|----------|
| `VPS_PUBLIC_IP` | `203.0.113.10` | WireGuard endpoint, SSH ProxyJump |
| `VPS_USER` | `deploy` | VPS SSH |
| `HOME_PC_USER` | `homelab` | Local sudo user |
| `HOME_PC_VPN_IP` | `10.8.0.2` | WireGuard address on home PC |
| `VPS_VPN_IP` | `10.8.0.1` | WireGuard address on VPS |
| `WIFI_SSID` | `HomeNetwork` | Only if Wi-Fi not already connected |

### Execution rules

1. **One phase per session** when possible — verify before moving on.
2. Run commands yourself — do not only paste instructions.
3. **Never commit** `.env`, `*.key`, WireGuard private keys, WhatsApp session files.
4. Use scripts in `src/infra/` — do not duplicate logic in chat.
5. After each phase, run the **verification commands** from the runbook.
6. Update [DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md) when user confirms a phase is done.

### Security (non-negotiable)

- Home PC SSH **never** exposed to the public internet — WireGuard only.
- Store secrets in `.env` (chmod 600) or `/etc/wireguard/` (root only).
- Dedicated WhatsApp number; respect ToS and opt-in.

---

## Harness (development rules)

```bash
pip install -r .agent-harness/harness/requirements.txt
./agent-harness/rules-path.sh
./agent-harness/resolve-rules.sh security ssh wireguard   # infra tasks
```

Cursor applies `.cursor/rules/*.mdc` automatically.

---

## Repository layout

```
docs/
  AGENT-RUNBOOK.md       # ← execute this on the home PC
  HOME-PC-SETUP.md
  VPS-SETUP.md
  IMPLEMENTATION-PLAN.md
  DEPLOYMENT-CHECKLIST.md
src/infra/               # setup scripts (safe to run)
  setup-home-pc.sh
  watchdog.sh
  install-watchdog.sh
.env.example             # template — copy to .env
agent-rules/             # harness rules (symlink)
.cursor/rules/           # Cursor always-on rules
```

---

## Phase overview (summary)

| Phase | Where | Doc |
|-------|-------|-----|
| 1 | Home PC | [HOME-PC-SETUP.md](docs/HOME-PC-SETUP.md) — SSH, sleep, Wi-Fi |
| 2 | VPS | [VPS-SETUP.md](docs/VPS-SETUP.md) — ufw, WireGuard server |
| 3 | Both | WireGuard tunnel |
| 4 | Admin machine + VPS | SSH ProxyJump |
| 5–6 | Home PC | Node.js, PM2, bots |
| 7 | Both | Security hardening |
| 8 | Home PC | Wi-Fi watchdog |

Full commands: [AGENT-RUNBOOK.md](docs/AGENT-RUNBOOK.md).

---

## References

| Document | Purpose |
|----------|---------|
| [docs/AGENT-RUNBOOK.md](docs/AGENT-RUNBOOK.md) | Step-by-step agent execution |
| [docs/DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md) | Validation checklist |
| [LICENSE](LICENSE) | MIT |
| [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) | Third-party licenses |
