# UC04 — Auto-Reconnect After Network Drop

## Actor

Watchdog (`/usr/local/bin/watchdog.sh`), cron every 5 minutes.

## Preconditions

- WireGuard enabled on boot
- NetworkManager with Wi-Fi `autoconnect yes`
- Watchdog installed via `src/infra/install-watchdog.sh`

## Main flow — healthy tunnel

1. Cron runs watchdog.
2. `ping -c 2 10.8.0.1` succeeds.
3. Watchdog exits.

## Main flow — tunnel or Wi-Fi down

1. Ping to VPS VPN IP fails.
2. Watchdog restarts WireGuard: `systemctl restart wg-quick@wg0`.
3. Watchdog cycles Wi-Fi: `nmcli radio wifi off` → sleep 3s → `on`.
4. NetworkManager reconnects; WireGuard restores tunnel.
5. Next cron cycle confirms recovery.

## Alternate flow — persistent failure

1. Watchdog fails 3+ cycles (15+ min).
2. Admin detects via `ssh homerelay` unavailable.
3. Physical check: router, Wi-Fi signal, power.

## Postconditions

- WireGuard tunnel restored.
- Bots resume normal operation.

## Business rules

- Check interval: 5 minutes.
- Restart Wi-Fi only after tunnel ping failure.
- BIOS: auto power-on after outage.

## References

- [AGENT-RUNBOOK.md](../AGENT-RUNBOOK.md) Phase 8
- [GLOSSARY.md](../GLOSSARY.md#watchdog)
