#!/usr/bin/env bash
# One-shot: SSH config + desktop launcher (Pop!_OS / admin machine)
#
# Usage:
#   VPS_PUBLIC_IP=1.2.3.4 VPS_USER=root HOME_PC_USER=you bash src/client/setup-client.sh
#
# Or with defaults from .env in repo root:
#   bash src/client/setup-client.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

VPS_PUBLIC_IP="${VPS_PUBLIC_IP:-}"
VPS_USER="${VPS_USER:-root}"
HOME_PC_USER="${HOME_PC_USER:-}"
HOME_PC_VPN_IP="${HOME_PC_VPN_IP:-10.8.0.2}"

if [[ -z "$VPS_PUBLIC_IP" || -z "$HOME_PC_USER" ]]; then
  echo "Set required variables:" >&2
  echo "  VPS_PUBLIC_IP=... HOME_PC_USER=... bash $0" >&2
  echo "Optional: VPS_USER (default root), HOME_PC_VPN_IP (default 10.8.0.2)" >&2
  exit 1
fi

SSH_DIR="${HOME}/.ssh"
CONFIG="${SSH_DIR}/config"
KEY="${SSH_DIR}/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ ! -f "$KEY" ]]; then
  echo "==> Generating SSH key..."
  ssh-keygen -t ed25519 -f "$KEY" -N "" -C "homerelay-admin"
  chmod 600 "$KEY"
  echo "    Add this public key to VPS and home PC authorized_keys:"
  cat "${KEY}.pub"
  echo ""
fi

if [[ -f "$CONFIG" ]] && grep -q "^Host homerelay$" "$CONFIG" 2>/dev/null; then
  echo "==> SSH config: homerelay already present — skipping"
else
  echo "==> Writing SSH config..."
  [[ -f "$CONFIG" ]] && cp "$CONFIG" "${CONFIG}.bak.$(date +%s)"
  cat >> "$CONFIG" <<EOF

# HomeRelay — added by setup-client.sh
Host homerelay-vps
    HostName ${VPS_PUBLIC_IP}
    User ${VPS_USER}
    IdentityFile ~/.ssh/id_ed25519

Host homerelay
    HostName ${HOME_PC_VPN_IP}
    User ${HOME_PC_USER}
    ProxyJump homerelay-vps
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host homerelay-desktop
    HostName ${HOME_PC_VPN_IP}
    User ${HOME_PC_USER}
    ProxyJump homerelay-vps
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 3389 127.0.0.1:3389
    ServerAliveInterval 60
EOF
  chmod 600 "$CONFIG"
fi

echo "==> Installing desktop launcher..."
bash "${REPO_ROOT}/src/client/install-launcher.sh"

echo ""
echo "Done. Open 'HomeRelay' from the app menu."
echo "Test: ssh homerelay 'hostname'"
echo ""
if [[ -f "${KEY}.pub" ]]; then
  echo "If first run, copy key to servers:"
  echo "  ssh-copy-id ${VPS_USER}@${VPS_PUBLIC_IP}"
  echo "  ssh-copy-id -o ProxyJump=${VPS_USER}@${VPS_PUBLIC_IP} ${HOME_PC_USER}@${HOME_PC_VPN_IP}"
fi
