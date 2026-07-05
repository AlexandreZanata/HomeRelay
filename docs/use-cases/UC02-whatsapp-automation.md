# UC02 — Automated WhatsApp Messaging

## Actor

Automation bot (Node.js process managed by PM2).

## Preconditions

- Node.js LTS via nvm on home PC
- Baileys or whatsapp-web.js configured
- WhatsApp session authenticated (QR scan with dedicated number)
- PM2 running bot with auto-restart

## Main flow

1. Bot starts on boot (PM2).
2. Bot restores persisted WhatsApp session.
3. Bot waits for trigger (cron, webhook, or internal queue).
4. Bot sends message to configured recipient(s).
5. Bot logs success or error.

## Alternate flow — session expired

1. Bot detects WhatsApp disconnect.
2. Bot outputs new QR code (log or file).
3. Admin SSHs in (`ssh homerelay`) and scans QR.
4. Bot reconnects and resumes.

## Alternate flow — ban or rate limit

1. WhatsApp returns ban/limit error.
2. Bot stops sends and logs critical alert.
3. Admin reduces volume or pauses automation.

## Postconditions

- Message delivered or error logged with timestamp.
- Session kept for next run.

## Business rules

- **Dedicated number** only — never personal.
- Respect send rate limits.
- Opt-in contacts only.
- Baileys preferred on low RAM; whatsapp-web.js OK on 22 GB RAM.

## References

- [AGENT-RUNBOOK.md](../AGENT-RUNBOOK.md) Phases 5–6
- [GLOSSARY.md](../GLOSSARY.md#dedicated-whatsapp-number)
