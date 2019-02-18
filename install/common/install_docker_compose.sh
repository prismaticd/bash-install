#!/usr/bin/env bash


DOCKER_COMPOSE_V="1.23.2"
DOCKER_COMPOSE_LINK="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_V}/docker-compose-$(uname -s)-$(uname -m)"
DISTRIB_NAME="ubuntu"
#DISTRIB_VERSION="xenial"
DISTRIB_VERSION="bionic"

sudo sh -c  "curl -L $DOCKER_COMPOSE_LINK > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

LATEST="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
echo "Docker compose installed is $DOCKER_COMPOSE_V latest is $LATEST"

