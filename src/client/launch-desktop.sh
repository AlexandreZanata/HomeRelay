#!/usr/bin/env bash
# HomeRelay — remote desktop in work area (keeps local dock visible)
set -euo pipefail

DIR="${HOME}/.local/share/homerelay"
LOCK="${DIR}/desktop.lock"
LOG="${DIR}/launch.log"
PASSFILE="${DIR}/rdp-password"
SIZEFILE="${DIR}/remote-size"
TUNNEL_HOST="${HOMERELAY_TUNNEL_HOST:-homerelay-desktop}"
SSH_HOST="${HOMERELAY_SSH_HOST:-homerelay}"
RDP_USER="${HOMERELAY_RDP_USER:-}"
if [[ -z "$RDP_USER" ]]; then
  RDP_USER=$(grep -A10 "^Host[[:space:]]+${SSH_HOST}([[:space:]]|$)" "${HOME}/.ssh/config" 2>/dev/null \
    | grep -m1 '^[[:space:]]*User' | awk '{print $2}' || true)
fi
RDP_USER="${RDP_USER:-${USER}}"
RDP_HOST="127.0.0.1:3389"

mkdir -p "$DIR"
exec 9>"$LOCK"
if ! flock -n 9; then
  notify-send "HomeRelay" "Already connecting..." 2>/dev/null || true
  exit 0
fi

log() { echo "$(date -Iseconds) $*" >> "$LOG"; }
log "desktop launch"

notify-send "HomeRelay" "Connecting to home desktop..." 2>/dev/null || true

RDP_CLIENT=""
for candidate in xfreerdp3 xfreerdp; do
  if command -v "$candidate" &>/dev/null; then
    RDP_CLIENT="$candidate"
    break
  fi
done

if [[ -z "$RDP_CLIENT" ]]; then
  notify-send "HomeRelay" "Install: sudo apt install freerdp3-x11" -u critical 2>/dev/null || true
  flock -u 9
  exit 1
fi

if ! grep -qE "^Host[[:space:]]+${TUNNEL_HOST}([[:space:]]|$)" "${HOME}/.ssh/config" 2>/dev/null; then
  notify-send "HomeRelay" "Missing SSH Host ${TUNNEL_HOST} in ~/.ssh/config" -u critical 2>/dev/null || true
  flock -u 9
  exit 1
fi

# SSH tunnel (works from any WiFi — routes via VPS + WireGuard)
if ! ss -tln 2>/dev/null | grep -q ':3389 '; then
  log "starting ssh tunnel"
  ssh -f -N \
    -o Compression=no \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=60 \
    "${TUNNEL_HOST}"
  sleep 2
fi

if ! ss -tln 2>/dev/null | grep -q ':3389 '; then
  notify-send "HomeRelay" "Home PC offline — check WireGuard/SSH" -u critical 2>/dev/null || true
  log "tunnel failed"
  flock -u 9
  exit 1
fi

rm -f "${HOME}/.config/freerdp/server/127.0.0.1_3389.pem" 2>/dev/null || true

# Remote physical display size (GNOME mirrors screen — needs smart-sizing, not dynamic-resolution)
REMOTE_SIZE="${HOMERELAY_REMOTE_SIZE:-}"
if [[ -z "$REMOTE_SIZE" && -f "$SIZEFILE" && "${HOMERELAY_REFRESH_SIZE:-}" != "1" ]]; then
  REMOTE_SIZE=$(<"$SIZEFILE")
fi
if [[ -z "$REMOTE_SIZE" ]]; then
  REMOTE_SIZE=$(ssh -o ConnectTimeout=8 -o BatchMode=yes "$SSH_HOST" \
    "cat /sys/class/drm/card*-eDP-*/modes 2>/dev/null | head -1" 2>/dev/null || true)
  REMOTE_SIZE="${REMOTE_SIZE:-1366x768}"
  echo "$REMOTE_SIZE" >"$SIZEFILE"
  log "remote size ${REMOTE_SIZE}"
fi

# Password: saved file → env → zenity (password only, user is pre-set)
RDP_PASSWORD="${HOMERELAY_RDP_PASSWORD:-}"
if [[ -z "$RDP_PASSWORD" && -f "$PASSFILE" ]]; then
  RDP_PASSWORD=$(<"$PASSFILE")
fi
if [[ -z "$RDP_PASSWORD" ]]; then
  if command -v zenity &>/dev/null; then
    RDP_PASSWORD=$(zenity --password --title="HomeRelay" \
      --text="Home PC password (${RDP_USER}):" 2>/dev/null) || { flock -u 9; exit 0; }
  else
    read -rsp "HomeRelay password (${RDP_USER}): " RDP_PASSWORD
    echo
  fi
fi

# Performance: fast | balanced | quality  (HOMERELAY_PERF)
PERF="${HOMERELAY_PERF:-balanced}"
GFX_MODE="${HOMERELAY_GFX:-}"
case "$PERF" in
  fast)
    GFX_MODE="${GFX_MODE:-RFX}"
    PERF_ARGS=(+async-update +async-channels -wallpaper -themes -aero -menu-anims /audio-mode:0 /rfx-mode:video /compression-level:0)
    ;;
  quality)
    GFX_MODE="${GFX_MODE:-AVC444}"
    PERF_ARGS=(+clipboard)
    ;;
  *) # balanced — responsive + good image
    GFX_MODE="${GFX_MODE:-AVC444}"
    PERF_ARGS=(+async-update +async-channels -wallpaper -themes -menu-anims /audio-mode:0 /compression-level:0 +clipboard)
    ;;
esac

# smart-sizing scales remote desktop; +workarea keeps Pop!_OS dock visible
RDP_ARGS=(
  "/v:${RDP_HOST}"
  "/u:${RDP_USER}"
  "/p:${RDP_PASSWORD}"
  "/cert:ignore"
  "/sec:nla"
  "/gfx:${GFX_MODE}:on"
  "/network:lan"
  "/smart-sizing:${REMOTE_SIZE}"
  "+workarea"
  "/floatbar:default:hidden"
  "/t:HomeRelay"
  "${PERF_ARGS[@]}"
)

log "opening ${RDP_CLIENT} perf=${PERF} gfx=${GFX_MODE} size=${REMOTE_SIZE}"
flock -u 9
exec "$RDP_CLIENT" "${RDP_ARGS[@]}"
