#!/bin/bash

# forçar o download das imagens antes do init, o que evita timeouts:
sudo kubeadm config images pull

# Forçar o uso do IP fixo da rede privada para o cluster
sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16

# Configurar kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instalar rede Flannel
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Baixa o manifesto, ajusta para usar a eth1 (rede privada do Vagrant) e aplica
curl -sSL https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml | sed 's/--kube-subnet-mgr/--kube-subnet-mgr\n        - --iface=eth1/' | kubectl apply -f -

# Criar o join.sh com o IP CORRETO (192.168.56.10)
TOKEN=$(kubeadm token create --print-join-command)
echo "sudo $TOKEN" > /vagrant/join.sh
chmod +x /vagrant/join.sh


