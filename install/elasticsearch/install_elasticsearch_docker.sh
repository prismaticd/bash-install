#!/usr/bin/env bash

set -e
source ../common/install_docker.sh
source ../common/install_docker_compose.sh

sudo apt install pwgen

MAIN_FOLDER=/opt/elasticsearch/

sudo mkdir -p ${MAIN_FOLDER}
sudo mkdir -p "${MAIN_FOLDER}data/"


GRAYLOG_PASSWORD_SECRET=$(pwgen -N 1 -s 96)
GRAYLOG_ADMIN_PASSWORD=$(pwgen -N 1 -s 32)
GRAYLOG_ADMIN_PASSWORD_SHA2=$(echo -n ${GRAYLOG_ADMIN_PASSWORD} | shasum -a 256)

# RENDER TEMPLATE templates/docker_compose.yml INTO /opt/elasticsearch/docker-compose.yml OVERRIDE

cd ${MAIN_FOLDER}
sudo docker-compose pull

