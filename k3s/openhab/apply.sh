sudo kubectl create namespace mr-do-openhab

sudo kubectl apply -f mr-do-openhab-pv.yml
sudo kubectl apply -f mr-do-openhab-pvc.yml
sudo kubectl apply -f mr-do-openhab-services.yml
sudo kubectl apply -f mr-do-openhab-deployment.yml

sudo kubectl describe pod mr-do-openhab -n mr-do-openhab
sudo kubectl get pods --all-namespaces -o wide

sudo kubectl describe pv mr-do-openhab-pv-data -n mr-do-openhab
sudo kubectl describe pvc mr-do-openhab-pvc-data -n mr-do-openhab

sudo kubectl get svc -n mr-do-openhab
sudo kubectl describe services mr-do-openhab-service -n mr-do-openhab

sudo kubectl get all -n mr-do-openhab

# sudo kubectl log <containername>
# sudo kubectl label nodes mr-00 cputype=arm64