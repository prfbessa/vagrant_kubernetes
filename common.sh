#!/bin/bash
set -e # Interrompe o script se houver erro

# 1. Atualizar e instalar ferramentas básicas que faltam na box
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates apt-transport-https

# 2. Desativar Swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 3. Configurar Repositório Kubernetes (v1.29)
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 4. Instalar Containerd e K8s
sudo apt-get update
sudo apt-get install -y containerd kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 5. Configuração do Containerd (Gera arquivo padrão se não existir)
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 6. Módulos do Kernel e rede
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system