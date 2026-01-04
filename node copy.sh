#!/bin/bash
# Aguarda o arquivo de join estar disponível e executa
while [ ! -f /vagrant/join.sh ]; do
  sleep 5
done
sudo sh /vagrant/join.sh