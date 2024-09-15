SECRET=$0
IP=$1
URL=https://${IP}:6443
echo https://${IP}:6443


# https://docs.k3s.io/datastore/ha-embedded
# https://docs.k3s.io/installation/uninstall
# docker exec -ti <container_id> reset-password
sudo apt-get update
sudo apt-get -y install linux-modules-extra-raspi curl
sudo apt-get -y install nfs-common

# Master
#curl -sfL https://get.k3s.io | sh -s server --cluster-init --token=${SECRET}
curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} sh -s - server --cluster-init --disable=servicelb --no-deploy=kubernetes-dashboard

# Disable ingress on all server
#--disable traefik

# Master Slave
curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} sh -s - server --server https://${IP}:6443 --disable=servicelb

# Slave
sudo curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} K3S_URL=https://${IP}:6443 sh -


# K3S_NODE_NAME="mr00" sh -
sudo curl -sfL https://get.k3s.io | K3S_TOKEN="mr_cluster_infra_20" sh -s - server --cluster-init --disable=servicelb
sudo curl -sfL https://get.k3s.io | K3S_TOKEN="mr_cluster_infra_20" sh -s - server --server https://192.168.00.200:6443 --disable=servicelb
sudo curl -sfL https://get.k3s.io | K3S_TOKEN="mr_cluster_infra_20" K3S_URL=https://192.168.00.200:6443 sh -s - agent

## Comon
#sed -e '/server \\/,$d' -e 's@ExecStart=.*@ExecStart=/usr/local/bin/k3s server@' -i /etc/systemd/system/k3s.service --disable=servicelb
#systemctl daemon-reload



# Check https://docs.k3s.io/advanced
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/


