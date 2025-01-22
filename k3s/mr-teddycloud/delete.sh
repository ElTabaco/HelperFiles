#kubectl delete -f mr-teddycloud-deployment.yml
#kubectl delete -f mr-teddycloud-service.yml
#kubectl delete -f mr-teddycloud-pvc.yml
#kubectl delete -f mr-teddycloud-pv.yml
#kubectl delete -f mr-teddycloud-ingress.yml
#kubectl delete all,ingress --all -n mr-teddycloud
kubectl delete all,deployment,pv,pvc --all -n mr-teddycloud
kubectl delete namespace mr-teddycloud