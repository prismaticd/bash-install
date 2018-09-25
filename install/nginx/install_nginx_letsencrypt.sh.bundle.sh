set -e
# START-INCLUDE: ../common/install_nginx.sh
DISTRIB_NAME="ubuntu"
DISTRIB_VERSION="bionic"
sudo apt-get update
sudo apt-get install apt-transport-https -y
curl -fsSL http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
echo "deb http://nginx.org/packages/$DISTRIB_NAME/ $DISTRIB_VERSION nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/$DISTRIB_NAME/ $DISTRIB_VERSION nginx" | sudo tee -a /etc/apt/sources.list.d/nginx.list
sudo apt-get update
sudo apt-get install  ca-certificates ntp htop ncdu git jq nginx -y

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished ../common/install_nginx.sh
# END-INCLUDE:  ../common/install_nginx.sh
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
# START-RENDERING TEMPLATE 
regex='\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}'
sudo echo "Rendering templates/default.conf into /etc/nginx/conf.d/default.conf"
template=$(echo "JHtHRU5FUkFURVNUUklOR30Kc2VydmVyIHsKICBsaXN0ZW4gODAgZGVmYXVsdF9zZXJ2ZXI7CiAgc2VydmVyX25hbWUgXzsKCiAgbG9jYXRpb24gfiAiXi9cLndlbGwta25vd24vYWNtZS1jaGFsbGVuZ2UvKFstX2EtekEtWjAtOV0rKSQiIHsKICAgIGRlZmF1bHRfdHlwZSB0ZXh0L3BsYWluOwogICAgcmV0dXJuIDIwMCAiJDEuJHtUSFVNQlBSSU5UfSI7CiAgfQoKICBsb2NhdGlvbiAvIHsKICAgIHJldHVybiAzMDEgaHR0cHM6Ly8kaG9zdCRyZXF1ZXN0X3VyaTsKICB9Cgp9CgpzZXJ2ZXIgewogICAgbGlzdGVuIDQ0MyBzc2wgZGVmYXVsdF9zZXJ2ZXI7CiAgICBzZXJ2ZXJfbmFtZSBfOwoKICAgIHJldHVybiAgICAgICA0NDQ7Cn0=" | base64 --decode)
    while IFS= read -r line; do
        newline=$line
        while [[ "$newline" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo ""$LHS"")"
            newline=${line//$LHS/$RHS}
        done
        echo "$newline"
    done < <(printf "%s\n" "$template") | sudo tee /etc/nginx/conf.d/default.conf > /dev/null 
# END-RENDERING TEMPLATE 
sudo service nginx restart
~/.acme.sh/acme.sh --upgrade --auto-upgrade
echo "Finished installing ssl with success"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/nginx/install_nginx_letsencrypt.sh