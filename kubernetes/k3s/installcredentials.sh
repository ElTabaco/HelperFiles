#!/usr/bin/env bash
# k3s credentials — loads token + server IP from .env for use with install.sh
#
# Usage:
#   source kubernetes/k3s/installcredentials.sh
#
# Or: copy .env.example to .env, fill in values, then source .env instead.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    . "$REPO_ROOT/.env"
    set +a
    echo "Loaded credentials from $REPO_ROOT/.env"
    echo "  K3S_SERVER=${K3S_SERVER:-<not set>}"
else
    echo "ERROR: $REPO_ROOT/.env not found."
    echo "Copy .env.example to .env and fill in the real values."
    exit 1
fi