# UC03 — Social Post Scheduling

## Actor

Post scheduler (Node.js/Python + cron, or n8n workflow).

## Preconditions

- Home PC online with WireGuard up
- API tokens in `.env` (never in git)
- Scheduler in PM2 or n8n via Docker/systemd

## Main flow (script + cron)

1. Admin defines posts and schedule in config or local DB.
2. Cron triggers script at scheduled time.
3. Script validates content (text, media, target network).
4. Script publishes via social API.
5. Script logs post ID, timestamp, errors.

## Main flow (n8n)

1. Admin builds visual workflow with schedule trigger.
2. n8n runs publish nodes on schedule.
3. Failures appear in n8n execution history.

## Alternate flow — publish failure

1. API returns error (expired token, rate limit, invalid media).
2. Scheduler logs failure; retries with backoff if configured.
3. Admin alerted if retries exhausted.

## Postconditions

- Post published or failure documented.
- Execution log available.

## Business rules

- Tokens in `.env` only.
- Validate media before publish.
- Respect platform rate limits.

## References

- [IMPLEMENTATION-PLAN.md](../IMPLEMENTATION-PLAN.md#phase-5--automations)
- [GLOSSARY.md](../GLOSSARY.md#n8n)
