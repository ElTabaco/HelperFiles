#!/usr/bin/env bash
# Remove MetalLB from the cluster, including the namespace.
# Removes finalizers if the namespace gets stuck (common with webhooks).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="metallb-system"
POOL="${SCRIPT_DIR}/manifests/ipaddresspool.yaml"
MANIFEST="${SCRIPT_DIR}/manifests/metallb-native.yaml"
AUTH_DELEGATOR="${SCRIPT_DIR}/manifests/auth-delegator.yaml"

echo "Deleting IPAddressPool + L2Advertisement..."
kubectl delete -f "${POOL}" --ignore-not-found=true --wait=false || true

echo "Deleting auth-delegator RBAC..."
kubectl delete -f "${AUTH_DELEGATOR}" --ignore-not-found=true --wait=false || true

echo "Deleting MetalLB core manifest..."
kubectl delete -f "${MANIFEST}" --ignore-not-found=true --wait=false || true

echo "Deleting namespace ${NAMESPACE}..."
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true --wait=false || true

echo "Waiting for namespace removal..."
for i in $(seq 1 10); do
  if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Namespace ${NAMESPACE} removed."
    exit 0
  fi
  phase="$(kubectl get namespace "${NAMESPACE}" -o jsonpath='{.status.phase}' 2>/dev/null || echo unknown)"
  echo "  Still present: phase=${phase} (${i}/10)"
  sleep 2
done

echo "Namespace stuck — removing finalizers..."
kubectl patch namespace "${NAMESPACE}" -p '{"spec":{"finalizers":[]}}' --type=merge || true

for i in $(seq 1 10); do
  if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Namespace ${NAMESPACE} removed (after finalizer patch)."
    exit 0
  fi
  echo "  Still present after patch (${i}/10)"
  sleep 2
done

echo "ERROR: namespace still stuck. Manual intervention needed:"
echo "  kubectl get namespace ${NAMESPACE} -o yaml"
exit 1
