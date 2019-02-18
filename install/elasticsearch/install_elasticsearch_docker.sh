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

#benoit@nocnoc-backend:/opt/elasticsearch$ sudo su
#root@nocnoc-backend:/opt/elasticsearch# echo -e "[Service]\nLimitMEMLOCK=infinity" | SYSTEMD_EDITOR=tee systemctl edit docker.service
#[Service]
#LimitMEMLOCK=infinity
echo "grep vm.max_map_count /etc/sysctl.conf"
echo "vm.max_map_count=262144"
echo "sysctl -w vm.max_map_count=262144"