#!/usr/bin/env bash


DOCKER_COMPOSE_V="1.21.0"
DOCKER_COMPOSE_LINK="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_V}/docker-compose-$(uname -s)-$(uname -m)"
DISTRIB_NAME="ubuntu"
DISTRIB_VERSION="xenial"

sudo sh -c  "curl -L $DOCKER_COMPOSE_LINK > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

LATEST="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
echo "Docker compose installed is $DOCKER_COMPOSE_V latest is $LATEST"

