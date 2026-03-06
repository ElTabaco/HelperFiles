#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
MANIFEST_FILE="install.yaml"
CMD_PARAMS_FILE="argocd-cmd-params-cm.yaml"
LOADBALANCER_IP="192.168.0.4"

echo "Ensuring namespace ${NAMESPACE} exists..."
kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

echo "Downloading latest Argo CD manifest..."
wget -q "${MANIFEST_URL}" -O "${MANIFEST_FILE}"

echo "Extracting CRDs..."
awk '
BEGIN {file=""}
/^---$/ {file=""; next}
/^kind: CustomResourceDefinition$/ {crd=1}
crd && /^metadata:$/ {meta=1}
crd {print > "/tmp/argocd-crds.yaml"}
' "${MANIFEST_FILE}"

echo "Applying Argo CD CRDs safely..."
kubectl create -f /tmp/argocd-crds.yaml 2>/dev/null || kubectl replace -f /tmp/argocd-crds.yaml

echo "Applying Argo CD install manifest..."
kubectl apply -f "${MANIFEST_FILE}" -n "${NAMESPACE}" || true

echo "Applying Argo CD cmd params config..."
kubectl apply -f "${CMD_PARAMS_FILE}"

echo "Restarting argocd-server..."
kubectl rollout restart deployment argocd-server -n "${NAMESPACE}"

echo "Waiting for Argo CD server..."
kubectl rollout status deployment argocd-server -n "${NAMESPACE}" --timeout=300s

echo "Patching argocd-server service..."
kubectl patch svc argocd-server -n "${NAMESPACE}" --type=merge -p "{
  \"spec\": {
    \"type\": \"LoadBalancer\",
    \"loadBalancerIP\": \"${LOADBALANCER_IP}\"
  }
}"

echo
echo "=== Argo CD resources ==="
kubectl get all -n "${NAMESPACE}"

echo
echo "=== Argo CD service ==="
kubectl get svc argocd-server -n "${NAMESPACE}" -o wide

echo
echo "=== Initial admin password ==="
kubectl -n "${NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d || true
echo