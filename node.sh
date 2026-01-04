#!/bin/bash

# Aguarda o arquivo de join estar disponível
while [ ! -f /vagrant/join.sh ]; do
  sleep 5
done

# AUTOMATIZAÇÃO: Limpa qualquer tentativa anterior que falhou (evita erro de arquivos existentes)
sudo kubeadm reset -f

# AUTOMATIZAÇÃO: Tenta o join com loop de repetição em caso de timeout
until sudo sh /vagrant/join.sh; do
  echo "Tentativa de Join falhou (provável timeout no Master). Reentando em 10 segundos..."
  sudo kubeadm reset -f
  sleep 10
done
