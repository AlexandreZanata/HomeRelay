# Domain Glossary

> Ubiquitous language for HomeRelay. Docs, scripts, and agents MUST use these terms consistently.

---

## Home PC

**Definition:** Physical machine at home running automations (WhatsApp bots, post scheduler).
**Not the same as:** VPS — no public IP; initiates outbound connections.
**VPN address:** `10.8.0.2` (default).

---

## VPS (Hub)

**Definition:** Cloud server with fixed public IP; entry point and relay to the home PC.
**Not the same as:** Home PC — does not run bots; holds tunnel and public SSH.
**VPN address:** `10.8.0.1` (default).

---

## CGNAT

**Definition:** Carrier-Grade NAT — ISP shares one public IP among residential subscribers.
**Impact:** No port forwarding; requires outbound tunnel (WireGuard).

---

## WireGuard Tunnel

**Definition:** Encrypted persistent VPN between home PC and VPS on `10.8.0.0/24`.
**Critical setting:** `PersistentKeepalive = 25` on home PC client.

---

## ProxyJump

**Definition:** SSH chaining: admin machine → VPS → home PC without exposing home PC to internet.
**Default alias:** `homerelay` in `~/.ssh/config`.

---

## Automation Bot

**Definition:** Node.js (or Python) process for scheduled tasks — WhatsApp, social posts.
**Management:** PM2 with auto-restart and boot persistence.

---

## Watchdog

**Definition:** Script at `/usr/local/bin/watchdog.sh`, cron every 5 min — restarts WireGuard/Wi-Fi if tunnel fails.
**Why:** Wi-Fi is less stable than Ethernet.

---

## Baileys

**Definition:** Node.js WhatsApp library via native protocol — no Chromium.
**Preference:** Low RAM systems.

---

## whatsapp-web.js

**Definition:** Popular Node.js WhatsApp via Puppeteer/Chromium headless.
**Trade-off:** Higher RAM — fine on 22 GB systems.

---

## n8n

**Definition:** Self-hosted visual automation (Docker) with social/WhatsApp nodes.
**When:** Complex workflows without custom code.

---

## PM2

**Definition:** Node.js process manager — keeps bots alive, survives reboot.
**Key commands:** `pm2 start`, `pm2 save`, `pm2 startup`.

---

## Dedicated WhatsApp Number

**Definition:** Separate phone line used only for message automations.
**Rule:** Never use personal number — ban risk.

---

## Agent Harness

**Definition:** Rules and scripts (`agent-rules/`, `.cursor/rules/`) guiding AI agents in this repo.
**Source:** [GoodPraticesForLLMSandAgents](https://github.com/AlexandreZanata/GoodPraticesForLLMSandAgents) (MIT).

---

## Open Source

**Definition:** MIT-licensed project — free to clone, modify, deploy on any PC.
**Secrets:** Local only (`.env`, disk files) — never in git.
