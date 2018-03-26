#!/usr/bin/env bash

# START-INCLUDE: ../common/install_docker.sh
sudo apt-get update
sudo apt install curl apt-transport-https ca-certificates -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install ntp htop ncdu jq docker-ce -y
sudo service docker start

# END-INCLUDE:  ../common/install_docker.sh
# START-INCLUDE: ../common/install_docker_compose.sh
DOCKER_COMPOSE_V="1.20.1"
DOCKER_COMPOSE_LINK="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_V}/docker-compose-$(uname -s)-$(uname -m)"
DISTRIB_NAME="ubuntu"
DISTRIB_VERSION="xenial"
sudo sh -c  "curl -L $DOCKER_COMPOSE_LINK > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
LATEST="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
echo "Docker compose installed is $DOCKER_COMPOSE_V latest is $LATEST"

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
template=$(echo "dmVyc2lvbjogJzInCnNlcnZpY2VzOgogIHNvbWUtbW9uZ286CiAgICBpbWFnZTogIm1vbmdvOjMiCiAgICB2b2x1bWVzOgogICAgICAtIC9vcHQvZ3JheWxvZy9kYXRhL21vbmdvOi9kYXRhL2RiCiAgc29tZS1lbGFzdGljc2VhcmNoOgogICAgaW1hZ2U6ICJlbGFzdGljc2VhcmNoOjUiCiAgICBlbnZpcm9ubWVudDoKICAgICAgaHR0cC5ob3N0OiAwLjAuMC4wCiAgICAgIHhwYWNrLnNlY3VyaXR5LmVuYWJsZWQ6ICdmYWxzZScKICAgIHZvbHVtZXM6CiAgICAgIC0gL29wdC9ncmF5bG9nL2RhdGEvZWxhc3RpY3NlYXJjaDovdXNyL3NoYXJlL2VsYXN0aWNzZWFyY2gvZGF0YQogIGdyYXlsb2c6CiAgICBpbWFnZTogZ3JheWxvZy9ncmF5bG9nOjIuNAogICAgdm9sdW1lczoKICAgICAgLSAvb3B0L2dyYXlsb2cvZGF0YS9qb3VybmFsOi91c3Ivc2hhcmUvZ3JheWxvZy9kYXRhL2pvdXJuYWwKICAgICAgIy0gL29wdC9ncmF5bG9nL2NvbmZpZzovdXNyL3NoYXJlL2dyYXlsb2cvZGF0YS9jb25maWcKICAgIGVudmlyb25tZW50OgogICAgICBHUkFZTE9HX1BBU1NXT1JEX1NFQ1JFVDogJHtHUkFZTE9HX1BBU1NXT1JEX1NFQ1JFVH0KICAgICAgIyBhZG1pbiAvLyAke0dSQVlMT0dfQURNSU5fUEFTU1dPUkR9CiAgICAgIEdSQVlMT0dfUk9PVF9QQVNTV09SRF9TSEEyOiAke0dSQVlMT0dfQURNSU5fUEFTU1dPUkRfU0hBMn0KICAgICAgR1JBWUxPR19XRUJfRU5EUE9JTlRfVVJJOiBodHRwOi8vMTI3LjAuMC4xOjkwMDAvYXBpCiAgICBsaW5rczoKICAgICAgLSBzb21lLW1vbmdvOm1vbmdvCiAgICAgIC0gc29tZS1lbGFzdGljc2VhcmNoOmVsYXN0aWNzZWFyY2gKICAgIHBvcnRzOgogICAgICAtICI5MDAwOjkwMDAiCiAgICAgIC0gIjEyMjAxOjEyMjAxIgogICAgICAtICIxMjIwMToxMjIwMS91ZHAiCiAgICAgIC0gIjE1MTQ6MTUxNCIKICAgICAgLSAiMTUxNDoxNTE0L3VkcCIKICAgICAgLSAiNTA0NDo1MDQ0IgogICAgICAtICI1MDQ0OjUwNDQvdWRwIgogICAgICAtICIxMjMwMToxMjMwMSIKICAgICAgLSAiMTIzMDE6MTIzMDEvdWRwIgogICAgICAtICIxMjMwMjoxMjMwMiIKICAgICAgLSAiMTIzMDI6MTIzMDIvdWRwIg==" | base64 --decode)
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
sudo docker-compose

