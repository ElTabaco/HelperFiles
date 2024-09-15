#!/bin/bash

echo "Full Upgrade"
sudo apt-get update
# sudo apt-get -y install & sudo apt-get -y full-upgrade

# https://github-wiki-see.page/m/spaceshiptrip/raspberrypi/wiki/Setup-Docker
sudo curl -fsSL https://get.docker.com |bash
sudo usermod -aG docker mr
#sudo apt purge --autoremove -y docker-compose

# Add user to docker group
sudo usermod -aG docker mr
# sudo gpasswd -a $USER docker
# https://github.com/slyfox1186/script-repo/blob/main/Bash/Misc/docker-compose-multi-arch.sh

#sudo docker-compose up --force-recreate --build -d

# sudo docker system -y prune -a && sudo docker container prune -f && sudo docker volume prune && sudo docker image prune -f

# Login
# sudo docker exec -u root -it <container_id> /bin/bash
# Ports:   https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/