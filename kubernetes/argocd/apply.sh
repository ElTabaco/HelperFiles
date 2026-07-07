#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
LOADBALANCER_IP="192.168.0.4"

kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

wget -q "${MANIFEST_URL}" -O install.yaml
kubectl apply -f install.yaml -n "${NAMESPACE}"
kubectl apply -f argocd-cmd-params-cm.yaml

# Set LoadBalancer with static IP
kubectl patch svc argocd-server -n "${NAMESPACE}" --type=merge -p "{\"spec\":{\"type\":\"LoadBalancer\",\"loadBalancerIP\":\"${LOADBALANCER_IP}\"}}"

# Get initial admin password
echo ""
echo "=== Admin password ==="
kubectl -n "${NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

kubectl get all -n "${NAMESPACE}"
