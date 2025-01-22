sudo kubectl apply -f helm-chart-config.yaml
sudo kubectl delete po argocd-server-xxxx-yyyy -n argocd

sudo kubectl get all -n argocd

