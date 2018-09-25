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
sudo apt install pwgen
MAIN_FOLDER=/opt/elasticsearch/
sudo mkdir -p ${MAIN_FOLDER}
sudo mkdir -p "${MAIN_FOLDER}data/"
GRAYLOG_PASSWORD_SECRET=$(pwgen -N 1 -s 96)
GRAYLOG_ADMIN_PASSWORD=$(pwgen -N 1 -s 32)
GRAYLOG_ADMIN_PASSWORD_SHA2=$(echo -n ${GRAYLOG_ADMIN_PASSWORD} | shasum -a 256)
# START-RENDERING TEMPLATE 
regex='\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}'
sudo echo "Rendering templates/docker_compose.yml into /opt/elasticsearch/docker-compose.yml"
template=$(echo "dmVyc2lvbjogJzMnCnNlcnZpY2VzOgogIHNvbWUtZWxhc3RpY3NlYXJjaDoKICAgIGltYWdlOiAiZG9ja2VyLmVsYXN0aWMuY28vZWxhc3RpY3NlYXJjaC9lbGFzdGljc2VhcmNoOjYuMi40IgogICAgZW52aXJvbm1lbnQ6CiAgICAgIGh0dHAuaG9zdDogMC4wLjAuMAogICAgICB4cGFjay5zZWN1cml0eS5lbmFibGVkOiAnZmFsc2UnCiAgICAgIGRpc2NvdmVyeS50eXBlOiAnc2luZ2xlLW5vZGUnCiAgICAgIGJvb3RzdHJhcC5tZW1vcnlfbG9jazogdHJ1ZQogICAgICBFU19KQVZBX09QVFM6ICItWG1zNTEybSAtWG14NTEybSIKICAgIHZvbHVtZXM6CiAgICAgICMgc3VkbyBta2RpciAuL2RhdGEgJiYgIHN1ZG8gY2hvd24gMTAwMCAuL2RhdGEvCiAgICAgIC0gL29wdC9lbGFzdGljc2VhcmNoL2RhdGE6L3Vzci9zaGFyZS9lbGFzaXRpY3NlYXJjaC9kYXRhCiAgICBwb3J0czoKICAgICAgLSAiOTIwMDo5MjAwIgogIHNvbWUta2liYW5hOgogICAgaW1hZ2U6ICJkb2NrZXIuZWxhc3RpYy5jby9raWJhbmEva2liYW5hOjYuMi40IgogICAgbGlua3M6CiAgICAgIC0gc29tZS1lbGFzdGljc2VhcmNoOmVsYXN0aWNzZWFyY2gKICAgIHBvcnRzOgogICAgICAtICI1NjAxOjU2MDEiCg==" | base64 --decode)
    while IFS= read -r line; do
        newline=$line
        while [[ "$newline" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo ""$LHS"")"
            newline=${line//$LHS/$RHS}
        done
        echo "$newline"
    done < <(printf "%s\n" "$template") | sudo tee /opt/elasticsearch/docker-compose.yml > /dev/null 
# END-RENDERING TEMPLATE 
cd ${MAIN_FOLDER}
sudo docker-compose pull

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/elasticsearch/install_elasticsearch_docker.sh