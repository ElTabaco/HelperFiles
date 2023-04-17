sudo kubectl create namespace openhab
sudo kubectl create -f openhab-pvcs.yml
sudo kubectl create -f openhab-deployment.yml
sudo kubectl create -f openhab-services.yml

sudo kubectl apply -f openhab-pvcs.yml
sudo kubectl apply -f openhab-deployment.yml
sudo kubectl apply -f openhab-services.yml

sudo kubectl get pods --all-namespaces