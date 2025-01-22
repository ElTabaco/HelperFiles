kubectl create namespace argocd
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -O install.yaml
# sed -i 's,quay.io/argoproj/argocd,alinbalutoiu/argocd,g' install.yaml
kubectl apply -f install.yaml -n argocd

kubectl apply -f argocd-cmd-params-cm.yaml 

# Use a LoadBalancer Service (Cloud Environments)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "loadBalancerIP": "192.168.0.4"}}'
kubectl patch svc argocd-server -n argocd --type='merge' -p '{"spec": {"type": "LoadBalancer", "loadBalancerIP": "<STATIC_IP>"}}'



* Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl get all -n argocd
