#!/usr/bin/env bash
# Install MetalLB on a k3s cluster using the vendored manifests.
#
# Usage:
#   ./apply.sh                          # uses default IP range 192.168.0.2-192.168.0.29
#   ./apply.sh 192.168.1.100 192.168.1.120   # custom IP range
#
# What it does:
#   1. Applies vendored metallb-native.yaml (v0.16.0, webhook failurePolicy patched to Ignore)
#   2. Waits for controller + speaker rollout
#   3. Applies IPAddressPool + L2Advertisement (local, editable)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="metallb-system"
MANIFEST="${SCRIPT_DIR}/manifests/metallb-native.yaml"
POOL="${SCRIPT_DIR}/manifests/ipaddresspool.yaml"

# IP range — override via args or env
IP_RANGE_START="${1:-${METALLB_IP_START:-192.168.0.2}}"
IP_RANGE_END="${2:-${METALLB_IP_END:-192.168.0.29}}"

echo "=== MetalLB install ==="
echo "  namespace:  ${NAMESPACE}"
echo "  manifest:   ${MANIFEST} (v0.16.0, webhook failurePolicy=Ignore)"
echo "  IP pool:    ${IP_RANGE_START}-${IP_RANGE_END}"
echo

# Sanity: manifests exist
if [[ ! -f "${MANIFEST}" || ! -f "${POOL}" ]]; then
  echo "ERROR: vendored manifest(s) missing. Expected:"
  echo "  ${MANIFEST}"
  echo "  ${POOL}"
  exit 1
fi

# Check namespace isn't stuck terminating
if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  ns_phase="$(kubectl get namespace "${NAMESPACE}" -o jsonpath='{.status.phase}')"
  if [[ "${ns_phase}" == "Terminating" ]]; then
    echo "ERROR: namespace ${NAMESPACE} is still Terminating. Wait for it to finish before reinstalling."
    exit 1
  fi
  echo "Namespace ${NAMESPACE} exists (${ns_phase}), continuing with apply..."
fi

echo "Applying MetalLB core manifest..."
kubectl apply -f "${MANIFEST}"

echo "Waiting for controller rollout..."
kubectl rollout status deployment/controller -n "${NAMESPACE}" --timeout=180s

echo "Waiting for speaker rollout..."
kubectl rollout status daemonset/speaker -n "${NAMESPACE}" --timeout=180s

# Substitute IP range into the pool manifest via a temp file
TMP_POOL="$(mktemp)"
trap 'rm -f "${TMP_POOL}"' EXIT
sed "s|192.168.0.2-192.168.0.29|${IP_RANGE_START}-${IP_RANGE_END}|g" "${POOL}" > "${TMP_POOL}"

echo "Applying IPAddressPool + L2Advertisement (${IP_RANGE_START}-${IP_RANGE_END})..."
kubectl apply -f "${TMP_POOL}"

echo
echo "=== MetalLB pods ==="
kubectl get pods -n "${NAMESPACE}" -o wide

echo
echo "=== MetalLB resources ==="
kubectl get all -n "${NAMESPACE}"

echo
echo "=== IPAddressPool ==="
kubectl get ipaddresspool -n "${NAMESPACE}" -o yaml
