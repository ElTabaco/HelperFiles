#!/bin/bash

echo "Full Upgrade"
sudo apt-get update
# sudo apt-get -y install & sudo apt-get -y full-upgrade

# https://github-wiki-see.page/m/spaceshiptrip/raspberrypi/wiki/Setup-Docker
sudo curl -fsSL https://get.docker.com |bash
sudo apt install -y docker-compose

# Add user to docker group
sudo usermod -aG docker mr

#sudo apt-get remove -y docker docker-engine docker.io containerd runc

#sudo apt-get install -y \
#    apt-transport-https \
#    ca-certificates \
#    curl \
#    gnupg \
#    lsb-release

#echo "DOCKER: https://docs.docker.com/engine/install/ubuntu/"
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#echo \
#  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#sudo apt-get update

#sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose

#sudo systemctl start docker.service
#sudo systemctl start containerd.service
#sudo systemctl enable docker.servicesus
#sudo systemctl enable containerd.service

#sudo docker-compose up --force-recreate --build -d

# Update
# sudo docker-compose kill
# sudo docker-compose stop
# sudo docker-compose rm
# sudo docker-compose pull
# sudo docker-compose up -d
 sudo docker system prune -a
 sudo docker container prune -f
sudo docker image prune
 sudo docker volume prune
 sudo docker image prune -f



# sudo docker system -y prune -a && sudo docker container prune -f && sudo docker volume prune && sudo docker image prune -f

# docker run -it --rm debian:bookworm-slim /bin/bash


# Login
# sudo docker exec -u root -it <container_id> /bin/bash
# Ports:   https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/