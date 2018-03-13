#!/bin/bash

sudo apt update
sudo apt install -y awscli
sudo snap install kubectl --classic

wget https://github.com/kubernetes/kops/releases/download/1.8.0/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops

cp /kube/config ~/.kube/config 
