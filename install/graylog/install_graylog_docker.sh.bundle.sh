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

sudo apt install pwgen

MAIN_FOLDER=/opt/graylog/

sudo mkdir -p ${MAIN_FOLDER}
sudo mkdir -p "${MAIN_FOLDER}data/"

GRAYLOG_PASSWORD_SECRET=$(pwgen -N 1 -s 96)
GRAYLOG_ADMIN_PASSWORD=$(pwgen -N 1 -s 32)
GRAYLOG_ADMIN_PASSWORD_SHA2=$(echo -n ${GRAYLOG_ADMIN_PASSWORD} | shasum -a 256)

# START-RENDERING TEMPLATE 
regex='\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}'
sudo echo "Rendering templates/docker_compose.yml into /opt/graylog/docker-compose.yml"
template=$(echo "dmVyc2lvbjogJzInCnNlcnZpY2VzOgogIHNvbWUtbW9uZ286CiAgICBpbWFnZTogIm1vbmdvOjMiCiAgICB2b2x1bWVzOgogICAgICAtIC9vcHQvZ3JheWxvZy9kYXRhL21vbmdvOi9kYXRhL2RiCiAgc29tZS1lbGFzdGljc2VhcmNoOgogICAgaW1hZ2U6ICJlbGFzdGljc2VhcmNoOjUiCiAgICAjIHZtLm1heF9tYXBfY291bnQgMjYyMTQ0CgogICAgZW52aXJvbm1lbnQ6CiAgICAgIHRyYW5zcG9ydC50eXBlOiBsb2NhbAogICAgICBpbmRleC5udW1iZXJfb2Zfc2hhcmRzOiAxCiAgICAgIGluZGV4Lm51bWJlcl9vZl9yZXBsaWNhczogMAogICAgICBodHRwLmhvc3Q6IDAuMC4wLjAKICAgICAgeHBhY2suc2VjdXJpdHkuZW5hYmxlZDogJ2ZhbHNlJwogICAgICBFU19KQVZBX09QVFM6ICItWG1zMTAyNG0gLVhteDEwMjRtIgogICAgdm9sdW1lczoKICAgICAgLSAvb3B0L2dyYXlsb2cvZGF0YS9lbGFzdGljc2VhcmNoOi91c3Ivc2hhcmUvZWxhc3RpY3NlYXJjaC9kYXRhCiAgZ3JheWxvZzoKICAgIGltYWdlOiBncmF5bG9nL2dyYXlsb2c6Mi40CiAgICB2b2x1bWVzOgogICAgICAtIC9vcHQvZ3JheWxvZy9kYXRhL2pvdXJuYWw6L3Vzci9zaGFyZS9ncmF5bG9nL2RhdGEvam91cm5hbAogICAgICAjIHN1ZG8gbWtkaXIgcGx1Z2lucyAmJiBjZCBwbHVnaW5zCiAgICAgICMgc3VkbyB3Z2V0IGh0dHBzOi8vZ2l0aHViLmNvbS9ncmF5bG9nLWxhYnMvZ3JheWxvZy1wbHVnaW4tc2xhY2svcmVsZWFzZXMvZG93bmxvYWQvMy4wLjEvZ3JheWxvZy1wbHVnaW4tc2xhY2stMy4wLjEuamFyCiAgICAgICMgY2QgLi4gJiYgc3VkbyBjaG93biAxMTAwIC1SIHBsdWdpbnMvCiAgICAgIC0gL29wdC9ncmF5bG9nL3BsdWdpbnMvZ3JheWxvZy1wbHVnaW4tc2xhY2stMy4wLjEuamFyOi91c3Ivc2hhcmUvZ3JheWxvZy9wbHVnaW4vZ3JheWxvZy1wbHVnaW4tc2xhY2stMy4wLjEuamFyCiAgICBlbnZpcm9ubWVudDoKICAgICAgR1JBWUxPR19QQVNTV09SRF9TRUNSRVQ6ICR7R1JBWUxPR19QQVNTV09SRF9TRUNSRVR9CiAgICAgICMgYWRtaW4gLy8gJHtHUkFZTE9HX0FETUlOX1BBU1NXT1JEfQogICAgICBHUkFZTE9HX1JPT1RfUEFTU1dPUkRfU0hBMjogJHtHUkFZTE9HX0FETUlOX1BBU1NXT1JEX1NIQTJ9CiAgICAgIEdSQVlMT0dfV0VCX0VORFBPSU5UX1VSSTogaHR0cDovLzEyNy4wLjAuMTo5MDAwL2FwaQogICAgbGlua3M6CiAgICAgIC0gc29tZS1tb25nbzptb25nbwogICAgICAtIHNvbWUtZWxhc3RpY3NlYXJjaDplbGFzdGljc2VhcmNoCiAgICBwb3J0czoKICAgICAgLSAiOTAwMDo5MDAwIgogICAgICAtICIxMjIwMToxMjIwMSIKICAgICAgLSAiMTIyMDE6MTIyMDEvdWRwIgogICAgICAtICIxNTE0OjE1MTQiCiAgICAgIC0gIjE1MTQ6MTUxNC91ZHAiCiAgICAgIC0gIjUwNDQ6NTA0NCIKICAgICAgLSAiNTA0NDo1MDQ0L3VkcCIKICAgICAgLSAiMTIzMDE6MTIzMDEiCiAgICAgIC0gIjEyMzAxOjEyMzAxL3VkcCIKICAgICAgLSAiMTIzMDI6MTIzMDIiCiAgICAgIC0gIjEyMzAyOjEyMzAyL3VkcCI=" | base64 --decode)
    while IFS= read -r line; do
        newline=$line
        while [[ "$newline" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo ""$LHS"")"
            newline=${line//$LHS/$RHS}
        done
        echo "$newline"
    done < <(printf "%s\n" "$template") | sudo tee /opt/graylog/docker-compose.yml > /dev/null 
# END-RENDERING TEMPLATE 
cd ${MAIN_FOLDER}
sudo docker-compose pull

echo 'add: 10 * * * * docker system  prune --filter "until=36h" --force && sudo docker volume  prune --force'

echo "$(date '+%Y-%m-%d %H:%M:%S') Finished /home/benoit/git/bash-install/install/graylog/install_graylog_docker.sh