#!/usr/bin/env bash
set -euo pipefail

METALLB_MANIFEST_URL="https://raw.githubusercontent.com/metallb/metallb/main/config/manifests/metallb-native.yaml"
POOL_TEMPLATE_URL="https://raw.githubusercontent.com/fabianlee/k3s-cluster-kvm/main/roles/k3s-metallb/templates/metallb-ipaddresspool.yml"

NAMESPACE="metallb-system"
POOL_FILE="metallb-ipaddresspool.yml"
MANIFEST_FILE="metallb-native.yaml"

IP_RANGE_START="192.168.0.2"
IP_RANGE_END="192.168.0.29"

echo "Downloading MetalLB manifest..."
wget -q "${METALLB_MANIFEST_URL}" -O "${MANIFEST_FILE}"

echo "Patching webhook failurePolicy for k3s..."
sed -i 's/failurePolicy: Fail/failurePolicy: Ignore/g' "${MANIFEST_FILE}"

echo "Downloading IPAddressPool template..."
wget -q "${POOL_TEMPLATE_URL}" -O "${POOL_FILE}"

echo "Replacing IP range in pool template..."
sed -i "s|{{metal_lb_primary}}-{{metal_lb_secondary}}|${IP_RANGE_START}-${IP_RANGE_END}|g" "${POOL_FILE}"

echo "Checking whether namespace ${NAMESPACE} is still terminating..."
if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  ns_phase="$(kubectl get namespace "${NAMESPACE}" -o jsonpath='{.status.phase}')"
  if [ "${ns_phase}" = "Terminating" ]; then
    echo "Namespace ${NAMESPACE} is still terminating. Wait until it is gone before reinstalling."
    exit 1
  fi
fi

echo "Applying MetalLB core manifest..."
kubectl apply -f "${MANIFEST_FILE}"

echo "Waiting for MetalLB controller rollout..."
kubectl rollout status deployment/controller -n "${NAMESPACE}" --timeout=180s

echo "Waiting for MetalLB speaker rollout..."
kubectl rollout status daemonset/speaker -n "${NAMESPACE}" --timeout=180s

echo "Applying MetalLB IPAddressPool and L2Advertisement..."
kubectl apply -f "${POOL_FILE}"

echo
echo "=== Pods (all namespaces) ==="
kubectl get pods --all-namespaces -o wide

echo
echo "=== MetalLB pods ==="
kubectl get pods -n "${NAMESPACE}" -o wide

echo
echo "=== MetalLB resources ==="
kubectl get all -n "${NAMESPACE}"

echo
echo "=== Controller description ==="
kubectl describe pod -n "${NAMESPACE}" -l app=metallb,component=controller



kubectl get ipaddresspool -n metallb-system first-pool -o yaml
