sudo kubectl create namespace mr-teddycloud
sudo kubectl apply -f mr-teddycloud-pv.yml
sudo kubectl apply -f mr-teddycloud-pvc.yml
sudo kubectl apply -f mr-teddycloud-service.yml
sudo kubectl apply -f mr-teddycloud-deployment.yml
#sudo kubectl apply -f mr-teddycloud-ingress.yml

sudo kubectl describe pod mr-teddycloud -n mr-teddycloud
sudo kubectl get pods -n mr-teddycloud -o wide
sudo kubectl get pods --all-namespaces -o wide



#sudo kubectl get ingress --all-namespaces -o wide
#sudo kubectl describe ingress -n mr-teddycloud

sudo kubectl get pv --all-namespaces -o wide
sudo kubectl get pvc --all-namespaces -o wide


sudo kubectl describe pv mr-teddycloud-pv-data -n mr-teddycloud
sudo kubectl describe pvc mr-teddycloud-pvc-data -n mr-teddycloud

sudo kubectl get configmap --all-namespaces -o wide

sudo kubectl get svc --all-namespaces
sudo kubectl get services  -n mr-teddycloud -o wide
sudo kubectl describe services mr-teddycloud-service -n mr-teddycloud

sudo kubectl get all -n mr-teddycloud

