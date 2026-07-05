# UC01 — Remote SSH Access to Home PC

## Actor

System administrator (you), from laptop or phone outside the home network.

## Preconditions

- WireGuard tunnel active: home PC (`10.8.0.2`) ↔ VPS (`10.8.0.1`)
- Ed25519 SSH key on admin machine
- `~/.ssh/config` with Host `homerelay` and ProxyJump to VPS

## Main flow

1. Admin runs `ssh homerelay` from any network.
2. SSH connects to VPS via public IP.
3. VPS forwards session over WireGuard to `10.8.0.2`.
4. Admin gets shell on home PC.
5. Admin manages bots, logs, and updates.

## Alternate flow — tunnel down

1. `ssh homerelay` times out.
2. Admin SSHs to VPS: `ssh user@VPS_PUBLIC_IP`.
3. Tests: `ping 10.8.0.2`.
4. If ping fails: `sudo wg show`; restart WireGuard or wait for watchdog.

## Postconditions

- Active SSH session on home PC.
- Home PC port 22 not exposed to public internet.

## Business rules

- `PasswordAuthentication no`.
- Ed25519 keys only.
- Home PC SSH accessible **only** via WireGuard.

## References

- [AGENT-RUNBOOK.md](../AGENT-RUNBOOK.md) Phase 4
- [GLOSSARY.md](../GLOSSARY.md#proxyjump)
