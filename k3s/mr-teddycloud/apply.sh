kubectl create namespace mr-teddycloud
kubectl apply -f mr-teddycloud-pv.yml
kubectl apply -f mr-teddycloud-pvc.yml
kubectl apply -f mr-teddycloud-service.yml
kubectl apply -f mr-teddycloud-deployment.yml
#kubectl apply -f mr-teddycloud-ingress.yml

kubectl describe pod mr-teddycloud -n mr-teddycloud
kubectl get pods -n mr-teddycloud -o wide
kubectl get pods --all-namespaces -o wide

#kubectl get ingress --all-namespaces -o wide
#kubectl describe ingress -n mr-teddycloud

kubectl get pv --all-namespaces -o wide
kubectl get pvc --all-namespaces -o wide
kubectl describe pv mr-teddycloud-pv-data -n mr-teddycloud
kubectl describe pvc mr-teddycloud-pvc-data -n mr-teddycloud

kubectl get configmap --all-namespaces -o wide

kubectl get svc --all-namespaces
kubectl get services  -n mr-teddycloud -o wide
kubectl describe services mr-teddycloud-service -n mr-teddycloud

kubectl get all -n mr-teddycloud

