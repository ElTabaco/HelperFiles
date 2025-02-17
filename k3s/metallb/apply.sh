# https://metallb.universe.tf/installation/

# download manifest
wget https://raw.githubusercontent.com/metallb/metallb/main/config/manifests/metallb-native.yaml -O metallb-native.yaml

# updating validatingwebhookconfigurations so it does not fail under k3s
sed -i 's/failurePolicy: Fail/failurePolicy: Ignore/' metallb-native.yaml

# or

# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

# https://metallb.universe.tf/configuration/

# Then create a MetalLB IP address pool to configure the IP addresses MetalLB should allocate.
wget https://raw.githubusercontent.com/fabianlee/k3s-cluster-kvm/main/roles/k3s-metallb/templates/metallb-ipaddresspool.yml -O metallb-ipaddresspool.yml

# change addresses to MetalLB endpoints
sed -i 's/{{metal_lb_primary}}-{{metal_lb_secondary}}/192.168.0.2 -192.168.0.29/' metallb-ipaddresspool.yml

# apply manifest
#kubectl apply -f metallb-config.yaml
kubectl apply -f metallb-native.yaml
kubectl apply -f metallb-ipaddresspool.yml

kubectl get pods --all-namespaces -o wide
kubectl get pods -n metallb-system -o wide
kubectl get all -n metallb-system
kubectl describe pod controller -n metallb-system
