#!/usr/bin/env bash

set -e
source ../common/install_nginx.sh

DATE=`date '+%Y-%m-%d %H:%M:%S'`
GENERATESTRING="# Generated by install_nginx_letsencrypt.sh"

if grep -Fxq "${GENERATESTRING}" /etc/nginx/conf.d/default.conf
then
    echo "Nginx Default was already installed not generating THUMBRINT"
else
curl https://get.acme.sh | sh
    register=$(~/.acme.sh/acme.sh --register-account)
    function regex1 { gawk 'match($0,/'$1'/, ary) {print ary['${2:-'1'}']}'; }
    THUMBPRINT=$(echo $register | regex1 "THUMBPRINT='(.*)'")
# RENDER TEMPLATE templates/default.conf INTO /etc/nginx/conf.d/default.conf OVERRIDE
    sudo service nginx restart
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
    echo "Finished installing ssl with success"
fi


