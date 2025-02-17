#!/bin/bash

# https://rancher.com/docs/k3s/latest/en/installation/install-options/
# tutorial: https://www.puzzle.ch/de/blog/articles/2020/10/13/k3s-on-raspberry-pi
# Converting docer-compose: https://microk8s.io/docs
# 

# Preperation 
# Add to /boot/cmdline.txt 
# cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
echo "install Rancher K3s Master" 
sudo apt-get update

# Tuturial k3s cluster
# https://learn.networkchuck.com/courses/take/ad-free-youtube-videos/lessons/26093614-i-built-a-raspberry-pi-super-computer-ft-kubernetes-k3s-cluster-w-rancher


sudo iptables -F 
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy 
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy 
sudo reboot
#sudo curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - --docker

export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC=" --disable servicelb --disable traefik --no-deploy kubernetes-dashboard"
curl -sfL https://get.k3s.io | sh - s -

sudo cat /var/lib/rancher/k3s/server/node-token
#cp /etc/rancher/k3s/k3s.yaml .kube/config/k3s.yaml






echo "Check nodes"

sudo -i
swapoff -a
exit
strace -eopenat kubectl version

kubectl get nodes





echo "Install Helm"
# Install Helm
# https://helm.sh/docs/intro/install/
#curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


echo "Install MetalLB (Load Balancer)"
# https://gist.github.com/kopwei/47dfd853261f36943aee80cc7fa5e1aa
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install metallb stable/metallb --namespace kube-system \
    --set configInline.address-pools[0].name=default \
    --set configInline.address-pools[0].protocol=layer2 \
    --set configInline.address-pools[0].addresses[0]=192.168.0.3-192.168.0.10



echo "Use Helm(v3) to install ingress controller"
# https://github.com/kubernetes/ingress-nginx
kubectl create namespace ingress-controller
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-controller \
  --set defaultBackend.enabled=false

kubectl get pods -n ingress-controller -l app=nginx-ingress

echo "Install the cert-manager for Rancher"
# https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/
# If you have installed the CRDs manually instead of with the `--set installCRDs=true` option added to your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart:
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.1
# Check
kubectl get pods --namespace cert-manager


echo "Install Rancher"

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system

#helm upgrade --install rancher rancher-latest/rancher \
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=redrancher.my.org \
  --set ingress.tls.source=rancher \
  --set replicas=1

# if error Rancher-webhook fails due to not existing rancher-webhook-tls secret
#kubectl delete -n cattle-system MutatingWebhookConfiguration rancher.cattle.io

kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get pods
#https://rancher.com/docs/rancher/v2.5/en/installation/resources/troubleshooting/
#kubectl -n cattle-system describe pod


#If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:
#echo https://redrancher.my.org/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

#To get just the bootstrap password on its own, run:
#kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'




#https://metallb.universe.tf/installation/
#kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
#kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml



#helm install metallb bitnami/metallb --namespace kube-system \
#    --set configInline.address-pools[0].name=default \
#    --set configInline.address-pools[0].protocol=layer2 \
#    --set configInline.address-pools[0].addresses[0]=192.168.0.3-192.168.0.5





