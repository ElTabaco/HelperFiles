SECRET="mr_cluster_secret"
IP=192.168.XX.XX
echo https://${IP}:6443

# docker exec -ti <container_id> reset-password

sudo apt-get -y install linux-modules-extra-raspi 

# Master
#curl -sfL https://get.k3s.io | sh -s server --cluster-init --token ${SECRET}
curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} sh -s - server --cluster-init

# Master Slave
#curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} sh -s - server --server https://${IP}:6443

# Slave
sudo curl -sfL https://get.k3s.io | K3S_TOKEN=${SECRET} K3S_URL=https://${IP}:6443 sh -

# K3S_NODE_NAME="redNode1" sh -


# Comon
sed -e '/server \\/,$d' -e 's@ExecStart=.*@ExecStart=/usr/local/bin/k3s server@' -i /etc/systemd/system/k3s.service
systemctl daemon-reload

# Check https://docs.k3s.io/advanced
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/
sudo kubectl get nodes
sudo kubectl get pods --all-namespaces

