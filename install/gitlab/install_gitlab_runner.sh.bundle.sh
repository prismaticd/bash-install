#!/usr/bin/env bash

# START-INCLUDE: ../common/install_docker.sh
DISTRIB="bionic"
sudo apt-get update
sudo apt install curl apt-transport-https ca-certificates -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${DISTRIB} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install ntp htop ncdu jq docker-ce -y
sudo usermod -aG docker ${USER}
sudo service docker start

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished ../common/install_docker.sh" 
# END-INCLUDE:  ../common/install_docker.sh
sudo apt-get update
sudo apt-get upgrade -y
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install gitlab-runner -y
sudo apt-get autoremove -y
sudo adduser gitlab-runner docker
echo 'sudo gitlab-runner register --url https://gitlab.com --name $HOSTNAME --tag-list linux,shell --executor shell'

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/gitlab/install_gitlab_runner.sh" 