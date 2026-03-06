#!/usr/bin/env bash
set -euo pipefail

METALLB_MANIFEST_URL="https://raw.githubusercontent.com/metallb/metallb/main/config/manifests/metallb-native.yaml"
POOL_TEMPLATE_URL="https://raw.githubusercontent.com/fabianlee/k3s-cluster-kvm/main/roles/k3s-metallb/templates/metallb-ipaddresspool.yml"

MANIFEST_FILE="metallb-native.yaml"
POOL_FILE="metallb-ipaddresspool.yml"
NAMESPACE="metallb-system"

IP_RANGE_START="192.168.0.2"
IP_RANGE_END="192.168.0.29"

wget -q "${METALLB_MANIFEST_URL}" -O "${MANIFEST_FILE}"
sed -i 's/failurePolicy: Fail/failurePolicy: Ignore/g' "${MANIFEST_FILE}"

wget -q "${POOL_TEMPLATE_URL}" -O "${POOL_FILE}"
sed -i "s|{{metal_lb_primary}}-{{metal_lb_secondary}}|${IP_RANGE_START}-${IP_RANGE_END}|g" "${POOL_FILE}"

kubectl apply -f "${MANIFEST_FILE}"
kubectl rollout status deployment/controller -n "${NAMESPACE}" --timeout=180s
kubectl rollout status daemonset/speaker -n "${NAMESPACE}" --timeout=180s

kubectl apply -f "${POOL_FILE}"

kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get all -n "${NAMESPACE}"
kubectl get ipaddresspools,l2advertisements -n "${NAMESPACE}"
