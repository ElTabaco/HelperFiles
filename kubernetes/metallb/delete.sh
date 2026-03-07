!/usr/bin/env bash
set -euo pipefail

NAMESPACE="metallb-system"

echo "Delete pool..."
kubectl delete -f metallb-ipaddresspool.yml --ignore-not-found=true --wait=false || true

echo "Delete MetalLB manifest..."
kubectl delete -f metallb-native.yaml --ignore-not-found=true --wait=false || true

echo "Delete namespace..."
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true --wait=false || true

echo "Wait briefly..."
for i in $(seq 1 10); do
  if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Namespace ${NAMESPACE} is gone."
    exit 0
  fi
  phase="$(kubectl get namespace "${NAMESPACE}" -o jsonpath='{.status.phase}' 2>/dev/null || echo unknown)"
  echo "Still present: phase=${phase} (${i}/10)"
  sleep 2
done

echo "Namespace stuck, removing finalizers with kubectl only..."
kubectl patch namespace "${NAMESPACE}" -p '{"spec":{"finalizers":[]}}' --type=merge || true

echo "Wait after patch..."
for i in $(seq 1 10); do
  if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Namespace ${NAMESPACE} removed."
    exit 0
  fi
  phase="$(kubectl get namespace "${NAMESPACE}" -o jsonpath='{.status.phase}' 2>/dev/null || echo unknown)"
  echo "Still present after patch: phase=${phase} (${i}/10)"
  sleep 2
done

echo "Still stuck. Current namespace state:"
kubectl get namespace "${NAMESPACE}" -o yaml || true



