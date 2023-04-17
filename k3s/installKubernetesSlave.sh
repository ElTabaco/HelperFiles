#!/bin/bash

# https://rancher.com/docs/k3s/latest/en/installation/install-options/
# tutorial: https://www.puzzle.ch/de/blog/articles/2020/10/13/k3s-on-raspberry-pi
# Converting docer-compose: https://microk8s.io/docs
# 

# Preperation 
# Add to /boot/cmdline.txt 
# cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory

echo "install Rancher K3s Slave"

sudo apt-get update

export K3S_KUBECONFIG_MODE="644"
export K3S_URL="https://192.168.XX.XX:6443"
export K3S_TOKEN="TOCKEN"
export K3S_NODE_NAME="redNode1"
#curl -sfL https://get.k3s.io | sh -


sudo curl -sfL https://get.k3s.io | K3S_TOKEN="$K3S_TOKEN K3S_URL="https://192.168.0.3:6443" K3S_NODE_NAME="mrsNode1" sh -

#https://github.com/k3s-io/k3s/blob/master/docker-compose.yml
#mkdir -p k3s
#cd k3s
#wget https://raw.githubusercontent.com/k3s-io/k3s/master/docker-compose.yml


echo "Check nodes"
sudo kubectl get nodes

