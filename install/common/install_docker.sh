#!/usr/bin/env bash



#DISTRIB="xenial"
DISTRIB="bionic"

sudo apt-get update
sudo apt install curl apt-transport-https ca-certificates -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${DISTRIB} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install ntp htop ncdu jq docker-ce -y
sudo usermod -aG docker ${USER}
sudo service docker start