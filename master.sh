#!/bin/bash
set -e

# Download de imagens
sudo kubeadm config images pull

# Inicialização do Cluster usando o IP fixo da eth1
sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16

# AUTOMATIZAÇÃO: Configura o acesso para o usuário vagrant
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

# AUTOMATIZAÇÃO: Adiciona KUBECONFIG ao bashrc para ser permanente no SSH
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Instalar rede Flannel forçando a interface eth1
curl -sSL https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml | sed 's/--kube-subnet-mgr/--kube-subnet-mgr\n        - --iface=eth1/' | sudo -u vagrant kubectl apply -f -

# Criar o join.sh para os nodes
TOKEN=$(kubeadm token create --print-join-command)
echo "sudo $TOKEN" > /vagrant/join.sh
chmod +x /vagrant/join.sh
