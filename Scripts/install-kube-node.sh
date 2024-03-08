#!/bin/bash

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# need to modify /etc/containerd/config.toml to comment out this line
# disabled_plugins = ["cri"]
# and restart containerd
# sudo systemctl restart containerd

# Install Docker
# sudo apt-get install docker.io
# sudo systemctl start docker
# sudo systemctl enable docker

# Add Kubernetes repository and install kubelet, kubeadm, and kubectl
sudo apt-get update 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

# Join the Kubernetes cluster
sudo kubeadm join 10.0.0.16:6443 --token cee55t.i4oyvr0g52t2q8nt --discovery-token-ca-cert-hash sha256:1c5fd76a299c2b15559bf4b520265c868deb458da2ae47977ae53e6c00fc72dd