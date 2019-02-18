#!/usr/bin/env bash
set -e

ELASTIC_APM_LINK="https://artifacts.elastic.co/downloads/apm-server/apm-server-6.5.3-amd64.deb"

TEMP_DEB="$(mktemp)" &&
wget -O "${TEMP_DEB}" ${ELASTIC_APM_LINK} &&
sudo dpkg -i "${TEMP_DEB}"
rm -f "${TEMP_DEB}"

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/elasticapm/install_elasticapm.sh" 