#sudo kubectl delete -f mr-teddycloud-deployment.yml
#sudo kubectl delete -f mr-teddycloud-service.yml
#sudo kubectl delete -f mr-teddycloud-pvc.yml
#sudo kubectl delete -f mr-teddycloud-pv.yml
#sudo kubectl delete -f mr-teddycloud-ingress.yml
#sudo kubectl delete all,ingress --all -n mr-teddycloud
sudo kubectl delete all,deployment,pv,pvc --all -n mr-teddycloud
sudo kubectl delete namespace mr-teddycloud