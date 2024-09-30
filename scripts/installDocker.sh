#!/bin/bash

echo "Full Upgrade"
sudo apt-get update
# sudo apt-get -y install & sudo apt-get -y full-upgrade

# https://github-wiki-see.page/m/spaceshiptrip/raspberrypi/wiki/Setup-Docker
sudo curl -fsSL https://get.docker.com |bash
echo "Add user to docker group"
sudo usermod -aG docker mr
#sudo apt purge --autoremove -y docker-compose

# sudo gpasswd -a $USER docker
# https://github.com/slyfox1186/script-repo/blob/main/Bash/Misc/docker-compose-multi-arch.sh

#sudo docker-compose up --force-recreate --build -d

# sudo docker system -y prune -a && sudo docker container prune -f && sudo docker volume prune && sudo docker image prune -f

# Login
# docker exec -u root -it <container_id> /bin/bash
# docker run --rm -u root -it -p 8200:8200 -p 12345:12345 --entrypoint sh alpine:latest
# docker run --rm --network host -it --entrypoint sh alpine:latest

# Ports:   https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/