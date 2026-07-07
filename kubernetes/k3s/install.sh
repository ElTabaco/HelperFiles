#!/usr/bin/env bash
# k3s cluster install — master, server-slave, and agent.
#
# Usage:
#   1. Copy .env.example to .env and fill in real values
#   2. source .env
#   3. sudo -E bash kubernetes/k3s/install.sh
#
# The -E flag preserves the K3S_SECRET and K3S_SERVER env vars under sudo.
set -euo pipefail

# Load .env if it exists (for direct execution without 'source .env')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    . "$REPO_ROOT/.env"
    set +a
fi

: "${K3S_SECRET:?K3S_SECRET not set — copy .env.example to .env and fill in the token}"
: "${K3S_SERVER:?K3S_SERVER not set — copy .env.example to .env and fill in the server IP}"

URL="https://${K3S_SERVER}:6443"
echo "k3s server: $URL"

# Install prerequisites
sudo apt-get update
sudo apt-get -y install curl nfs-common

# ── Master (cluster-init) ──
echo ""
echo "=== Install master (cluster-init) ==="
curl -sfL https://get.k3s.io | K3S_TOKEN="${K3S_SECRET}" sh -s - \
    server --cluster-init --disable=servicelb --write-kubeconfig-mode 644

# ── Master Slave (join existing cluster) ──
echo ""
echo "=== Install master-slave (join ${URL}) ==="
curl -sfL https://get.k3s.io | K3S_TOKEN="${K3S_SECRET}" sh -s - \
    server --server "${URL}" --disable=servicelb --write-kubeconfig-mode 644

# ── Agent (worker node) ──
echo ""
echo "=== Install agent ==="
curl -sfL https://get.k3s.io | K3S_TOKEN="${K3S_SECRET}" K3S_URL="${URL}" sh -

echo ""
echo "Done. Verify with: kubectl get nodes -o wide"