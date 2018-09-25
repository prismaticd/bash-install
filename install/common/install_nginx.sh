#!/usr/bin/env bash

DISTRIB_NAME="ubuntu"
#DISTRIB_VERSION="xenial"
DISTRIB_VERSION="bionic"

sudo apt-get update
sudo apt-get install apt-transport-https -y
curl -fsSL http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
echo "deb http://nginx.org/packages/$DISTRIB_NAME/ $DISTRIB_VERSION nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/$DISTRIB_NAME/ $DISTRIB_VERSION nginx" | sudo tee -a /etc/apt/sources.list.d/nginx.list
sudo apt-get update
sudo apt-get install  ca-certificates ntp htop ncdu git jq nginx -y
