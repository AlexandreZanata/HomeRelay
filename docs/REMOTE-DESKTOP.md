# Remote Desktop Access (Full GUI)

> **Goal:** One-click full desktop control of the home PC from any Wi-Fi network, via VPS + WireGuard + SSH tunnel + RDP.
>
> **Admin machine:** Pop!_OS / Ubuntu laptop. **Home PC:** Ubuntu 24.04 Desktop with GNOME Remote Desktop.

---

## Architecture

```
[Admin laptop]                    [VPS]                    [Home PC]
  homerelay-gui  ──SSH tunnel──►  ProxyJump  ──WireGuard──►  gnome-remote-desktop :3389
  xfreerdp3 → 127.0.0.1:3389     (public IP)               (CGNAT / Wi-Fi)
```

- RDP is **never** exposed to the internet.
- Traffic path: admin → VPS (SSH) → home PC VPN IP (`10.8.0.2`) → local RDP on port 3389.
- SSH `LocalForward 3389 127.0.0.1:3389` on host `homerelay-desktop` creates the tunnel.

---

## Why xfreerdp3 (not Remmina)

Ubuntu 24.04 **GNOME Remote Desktop** requires the RDP **Graphics Pipeline**. Remmina 1.4.35 (Ubuntu/Pop!_OS apt) does not advertise GFX support and fails after login with:

```text
[RDP] Client did not advertise support for the Graphics Pipeline, closing connection
```

**Solution:** `xfreerdp3` (`freerdp3-x11` package) with `/gfx:AVC444` or `/gfx:RFX`.

---

## One-time setup

### 1 — Home PC: enable RDP

Run **on the home PC** (logged into the desktop session):

```bash
cd /path/to/PC-ANTIGO-SERVIDOR
bash src/infra/setup-remote-desktop.sh
```

Or from admin machine (script is piped over SSH — sudo prompts must be done on home PC if needed):

```bash
ssh homerelay 'bash -s' < src/infra/setup-remote-desktop.sh
```

Set credentials manually if preferred:

```bash
grdctl rdp set-credentials YOUR_LINUX_USER 'YOUR_RDP_PASSWORD'
grdctl rdp disable-view-only
grdctl status
```

### 2 — Home PC: stay awake (lid closed, 24/7)

Run **on the home PC**:

```bash
bash src/infra/setup-server-awake.sh
```

Or paste the commands from [HOME-PC-SETUP.md](HOME-PC-SETUP.md#keep-awake-lid-closed).

**Also in BIOS:** enable *Power On After AC Loss*; keep laptop on AC power.

### 3 — Admin machine: SSH config

Ensure `~/.ssh/config` includes (see [ADMIN-CLIENT-SETUP.md](ADMIN-CLIENT-SETUP.md)):

```sshconfig
Host homerelay-desktop
    HostName <HOME_PC_VPN_IP>
    User <HOME_PC_USER>
    ProxyJump homerelay-vps
    IdentityFile ~/.ssh/id_ed25519
    Compression no
    LocalForward 3389 127.0.0.1:3389
    ServerAliveInterval 60
```

`Compression no` reduces latency on the tunnel.

### 4 — Admin machine: install launcher

```bash
cd /path/to/PC-ANTIGO-SERVIDOR
bash src/client/install-launcher.sh
```

Installs:

| Path | Purpose |
|------|---------|
| `~/.local/bin/homerelay-gui` | One-click remote desktop |
| `~/.local/bin/homerelay-save-password` | Save RDP password locally |
| `~/.local/share/applications/homerelay-desktop.desktop` | App menu entry |
| `~/.local/share/homerelay/launch-desktop.sh` | Main launcher script |

Requires `freerdp3-x11` (installed automatically if missing).

### 5 — Admin machine: save password (optional)

```bash
homerelay-save-password
```

Stores password in `~/.local/share/homerelay/rdp-password` (mode `600`). **Never commit this file.**

### 6 — Pin to dock (Pop!_OS COSMIC)

1. Remove any old **HomeRelay** dock pins (right-click → unpin).
2. Super → search **HomeRelay** → pin to dock.
3. App ID is `homerelay-desktop` (replaces legacy `homerelay` SSH-only launcher).

---

## Daily use

```bash
homerelay-gui
```

Or click the **HomeRelay** dock icon.

**Flow:**

1. Starts SSH tunnel to `homerelay-desktop` if port 3389 is not already forwarded.
2. Reads saved password (or shows zenity password dialog).
3. Opens `xfreerdp3` with smart-sizing and work-area mode.

**RDP login (if prompted):**

| Field | Value |
|-------|--------|
| Username | Linux user on home PC (from SSH config / `HOMERELAY_RDP_USER`) |
| Password | RDP password set with `grdctl` |
| Domain | *(leave empty)* |

---

## Display and performance tuning

### Black bars around remote desktop

GNOME mirrors the **physical** laptop screen. If the home PC is `1366x768` and the admin display is `1920x1080`, use **smart-sizing** (enabled by default). The launcher auto-detects remote resolution via SSH and caches it in `~/.local/share/homerelay/remote-size`.

Force refresh:

```bash
HOMERELAY_REFRESH_SIZE=1 homerelay-gui
```

### Keep local taskbar visible

The launcher uses `+workarea` (not fullscreen `/f`) so the Pop!_OS dock stays visible.

Toggle fullscreen inside session: `Ctrl+Alt+Enter`.

### Performance profiles

| Mode | Command | Trade-off |
|------|---------|-----------|
| **balanced** (default) | `homerelay-gui` | Good image + async updates |
| **fast** | `HOMERELAY_PERF=fast homerelay-gui` | Lower latency, RFX codec |
| **quality** | `HOMERELAY_PERF=quality homerelay-gui` | Best image, more bandwidth |

Override codec:

```bash
HOMERELAY_GFX=RFX homerelay-gui    # if AVC444 is unstable
```

### Server-side (optional)

On home PC — disable animations:

```bash
gsettings set org.gnome.desktop.interface enable-animations false
```

---

## SSH terminal only (no GUI)

```bash
ssh homerelay
# or
~/.local/share/homerelay/connect-homerelay.sh
```

---

## Environment variables (admin machine)

| Variable | Default | Description |
|----------|---------|-------------|
| `HOMERELAY_RDP_USER` | SSH `User` from config | RDP username |
| `HOMERELAY_RDP_PASSWORD` | from saved file / prompt | RDP password |
| `HOMERELAY_PERF` | `balanced` | `fast` \| `balanced` \| `quality` |
| `HOMERELAY_GFX` | auto per perf mode | `AVC444` \| `RFX` |
| `HOMERELAY_REMOTE_SIZE` | auto-detect | e.g. `1366x768` |
| `HOMERELAY_REFRESH_SIZE` | `0` | Set `1` to re-detect remote resolution |
| `HOMERELAY_TUNNEL_HOST` | `homerelay-desktop` | SSH host with LocalForward |
| `HOMERELAY_SSH_HOST` | `homerelay` | SSH host for resolution query |

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Notification only, no window | Invalid xfreerdp args (check `~/.local/share/homerelay/launch.log`) | Re-run `install-launcher.sh` |
| "Already connecting..." | Stale lock or old remmina/xfreerdp | `pkill xfreerdp3 remmina; homerelay-gui` |
| Disconnect after password | Remmina or old client | Use `homerelay-gui` (xfreerdp3 only) |
| Black bars | Resolution mismatch | smart-sizing (default); see above |
| Tunnel failed | Home PC offline | `ssh homerelay hostname` |
| Slow mouse | Internet + Wi-Fi latency | `HOMERELAY_PERF=fast homerelay-gui` |

**Logs:** `~/.local/share/homerelay/launch.log`

**Verify tunnel:**

```bash
ss -tln | grep 3389
ssh homerelay 'grdctl status | head -12'
```

---

## Security notes

- RDP password is stored only in `~/.local/share/homerelay/rdp-password` on the admin machine.
- No RDP port forwarding on the VPS firewall.
- Rotate RDP password: `grdctl rdp set-credentials USER 'NEW_PASSWORD'` on home PC, then `homerelay-save-password` on admin.
- Do not commit `.env`, WireGuard keys, or `rdp-password`.

---

## Files added/changed (this feature)

| File | Role |
|------|------|
| `src/client/launch-desktop.sh` | Tunnel + xfreerdp3 launcher |
| `src/client/save-rdp-password.sh` | Local password storage |
| `src/client/install-launcher.sh` | Install GUI + dock entry |
| `src/client/pin-to-dock.sh` | COSMIC dock + hicolor icons |
| `src/client/connect-homerelay.sh` | SSH terminal-only launcher |
| `src/infra/setup-remote-desktop.sh` | Enable GNOME RDP on home PC |
| `src/infra/setup-server-awake.sh` | Lid-close + no-suspend on home PC |
| `assets/homerelay-pc-icon.png` | Dock / app icon |

---

## Related docs

- [ADMIN-CLIENT-SETUP.md](ADMIN-CLIENT-SETUP.md) — SSH + Cursor remote
- [HOME-PC-SETUP.md](HOME-PC-SETUP.md) — Home PC baseline
- [use-cases/UC01-remote-ssh-access.md](use-cases/UC01-remote-ssh-access.md) — SSH flow
