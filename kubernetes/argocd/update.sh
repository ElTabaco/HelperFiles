#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
MANIFEST_FILE="install.yaml"
CMD_PARAMS_FILE="argocd-cmd-params-cm.yaml"
LOADBALANCER_IP="192.168.0.4"

kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

wget -q "${MANIFEST_URL}" -O "${MANIFEST_FILE}"

kubectl apply -f "${MANIFEST_FILE}" -n "${NAMESPACE}"
kubectl apply -f "${CMD_PARAMS_FILE}"

kubectl rollout restart deployment argocd-server -n "${NAMESPACE}"
kubectl rollout status deployment argocd-server -n "${NAMESPACE}" --timeout=300s

kubectl patch svc argocd-server -n "${NAMESPACE}" --type=merge -p "{\"spec\":{\"type\":\"LoadBalancer\",\"loadBalancerIP\":\"${LOADBALANCER_IP}\"}}"

kubectl get svc argocd-server -n "${NAMESPACE}" -o wide