
# Install podman
sudo apt-get update
sudo apt-get -y install podman podman-compose
podman --version
podman-compose --version


# Cleamup podman
    podman compose down
    podman compose stop
    podman compose kill
    podman compose rm
    # podman compose pull
    podman system prune -a
    podman container prune -f
    podman image prune
    podman volume prune
    podman image prune -f
    
    podman compose up -d

# Needful commands

# podman system -y prune -a && sudo podman container prune -f && sudo podman volume prune && sudo podman image prune -f

# podman run -it --rm debian:bookworm-slim /bin/bash
# podman run -it --rm alpine /bin/sh

# Login
# podman exec -u root -it /bin/bash <container_id> 
# Ports:   https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
