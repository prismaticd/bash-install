#!/usr/bin/env bash

source ../common/install_docker.sh

sudo apt-get update
sudo apt-get upgrade -y
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install gitlab-runner -y
sudo apt-get autoremove -y
sudo adduser gitlab-runner docker
echo 'sudo gitlab-runner register --url https://gitlab.com --name $HOSTNAME --tag-list linux,shell --executor shell'
