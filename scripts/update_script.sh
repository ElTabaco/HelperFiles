#!/bin/bash

# Variables
REMOTE_USER="mr"
#REMOTE_HOST="mrOffizeMini"
REMOTE_HOST="192.168.0.148"
REMOTE_SCRIPT_PATH="~/updateDebian.sh"
SSH_KEY_PATH="~/.ssh/id_rsa"  # typically ~/.ssh/id_rsa

# SSH into the remote machine and create the executable file
ssh -t -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'

chmod +x $REMOTE_SCRIPT_PATH
echo "System update start."

# Run the script

chmod +x ${REMOTE_SCRIPT_PATH}
${REMOTE_SCRIPT_PATH}

echo "System update completed successfully."

EOF
