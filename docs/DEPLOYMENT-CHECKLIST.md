# Deployment Checklist

> Check each item before moving to the next phase. **Agents:** update when the user confirms completion.

**Another PC?** Each machine is independent — generate **new WireGuard keys**. See [INSTALL-ON-ANOTHER-PC.md](INSTALL-ON-OTHER-PC.md).

---

## Phase 0 — Preparation

- [ ] Repository cloned (`git clone --recurse-submodules ...`)
- [ ] Cursor open on home PC with repo loaded
- [ ] `.env` created from `.env.example` (chmod 600)
- [ ] VPS provisioned (1 vCPU, 1–2 GB RAM)
- [ ] Dedicated WhatsApp number ready
- [ ] Wi-Fi credentials noted
- [ ] VPS public IP noted

---

## Phase 1 — Home PC OS

- [x] Linux installed (Ubuntu 24.04 LTS)
- [ ] `setup-home-pc.sh` completed
- [ ] SSH server enabled
- [ ] Wi-Fi autoconnect on boot
- [ ] Sleep/suspend disabled
- [ ] BIOS: Power On After Power Failure enabled
- [ ] UPS installed (recommended)

---

## Phase 2 — VPS

- [ ] System updated
- [ ] Non-root sudo user exists
- [ ] `ufw`: OpenSSH + UDP 51820
- [ ] Cloud security group: UDP 51820 open
- [ ] WireGuard installed

---

## Phase 3 — WireGuard

- [ ] Keys generated on VPS
- [ ] Keys generated on home PC
- [ ] `wg0.conf` on VPS
- [ ] `wg0.conf` on home PC (`PersistentKeepalive = 25`)
- [ ] `wg-quick@wg0` enabled both sides
- [ ] **Test:** `ping 10.8.0.2` from VPS

---

## Phase 4 — Remote SSH

- [ ] Ed25519 key on admin machine
- [ ] `ssh-copy-id` to VPS and home PC
- [ ] `~/.ssh/config` Host `homerelay` + ProxyJump
- [ ] **Test:** `ssh homerelay` from outside home
- [ ] `PasswordAuthentication no` on VPS and home PC

---

## Phase 5 — Automations

- [ ] nvm + Node.js LTS on home PC
- [ ] WhatsApp library chosen and bot working
- [ ] Post scheduler implemented (cron or n8n)
- [ ] **Test:** test message sent
- [ ] **Test:** scheduled post fires on time

---

## Phase 6 — PM2

- [ ] PM2 installed globally
- [ ] Bots registered with `pm2 start`
- [ ] `pm2 save` done
- [ ] `pm2 startup` systemd command applied
- [ ] **Test:** reboot → bots return

---

## Phase 7 — Security

- [ ] `ufw` on home PC
- [ ] `fail2ban` on VPS
- [ ] `unattended-upgrades` on both
- [ ] WireGuard private keys **not** in git
- [ ] Home PC SSH **not** on public internet

---

## Phase 8 — Wi-Fi stability

- [ ] Watchdog installed (`install-watchdog.sh`)
- [ ] Cron `*/5 * * * *` active
- [ ] **Test:** Wi-Fi reconnect within 5 min
- [ ] **Test:** power loss → PC boots

---

## Phase 9 — Final validation

- [ ] All tests in [IMPLEMENTATION-PLAN.md](IMPLEMENTATION-PLAN.md#final-test-checklist) passed
- [ ] Credentials stored in password manager
- [ ] Recovery procedure documented (WhatsApp QR, session restore)

---

## Sign-off

| Phase | Owner | Date | OK |
|-------|-------|------|----|
| OS + Wi-Fi | | | |
| VPS + WireGuard | | | |
| Remote SSH | | | |
| Automations + PM2 | | | |
| Security + Watchdog | | | |
