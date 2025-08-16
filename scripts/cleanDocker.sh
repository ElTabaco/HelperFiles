docker compose down
docker compose stop
docker compose kill
yes | docker compose rm
# docker compose pull
yes | docker system prune -a
yes | docker container prune -f
yes | docker image prune
yes | docker volume prune
yes | docker image prune -f

docker compose up -d



# docker system -y prune -a && sudo docker container prune -f && sudo docker volume prune && sudo docker image prune -f

# docker run -it --rm debian:bookworm-slim /bin/bash
# docker run -it --rm alpine /bin/sh

# Login
# docker exec -u root -it /bin/bash <container_id> 
# Ports:   https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
