#!/usr/bin/env bash

set -e
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

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished ../common/install_docker.sh
# END-INCLUDE:  ../common/install_docker.sh
# START-INCLUDE: ../common/install_docker_compose.sh
DOCKER_COMPOSE_V="1.22.0"
DOCKER_COMPOSE_LINK="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_V}/docker-compose-$(uname -s)-$(uname -m)"
DISTRIB_NAME="ubuntu"
DISTRIB_VERSION="bionic"
sudo sh -c  "curl -L $DOCKER_COMPOSE_LINK > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
LATEST="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
echo "Docker compose installed is $DOCKER_COMPOSE_V latest is $LATEST"

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished ../common/install_docker_compose.sh
# END-INCLUDE:  ../common/install_docker_compose.sh

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/docker/install_server_with_docker.sh