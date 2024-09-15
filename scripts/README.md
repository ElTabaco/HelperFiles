Using SSH keys is a more secure and preferred method for authenticating to remote machines. Here’s how you can modify the script to use SSH keys for authentication:

### Steps to Set Up SSH Key Authentication:

1. **Generate SSH Key Pair** (if you haven't already):
   ```sh
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```
   Follow the prompts to save the key, usually at `~/.ssh/id_rsa`.

2. **Copy the Public Key to the Remote Server**:
   ```sh
   ssh-copy-id your_remote_username@your_remote_host_ip_or_domain
   ```

### Script Using SSH Keys:

```sh
#!/bin/bash

# Variables
REMOTE_USER="your_remote_username"
REMOTE_HOST="your_remote_host_ip_or_domain"
REMOTE_SCRIPT_PATH="/tmp/update_script.sh"
SSH_KEY_PATH="/path/to/your/private_key"  # typically ~/.ssh/id_rsa

# SSH into the remote machine and create the executable file
ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
cat << 'SCRIPT' > ${REMOTE_SCRIPT_PATH}
#!/bin/bash
# This script updates the system and cleans up

# Update the package list
sudo apt-get update

# Upgrade all installed packages
sudo apt-get upgrade -y

# Perform distribution upgrade
sudo apt-get dist-upgrade -y

# Remove unused packages and clean up
sudo apt-get autoremove -y
sudo apt-get clean

echo "System update completed successfully."
SCRIPT

# Make the script executable
chmod +x ${REMOTE_SCRIPT_PATH}

# Run the script
${REMOTE_SCRIPT_PATH}

# Remove the script after execution (optional)
rm ${REMOTE_SCRIPT_PATH}
EOF
```

### Explanation:

1. **SSH Key Path**:
   - `SSH_KEY_PATH="/path/to/your/private_key"`: Specify the path to your private SSH key (usually `~/.ssh/id_rsa`).

2. **Use SSH with Key**:
   - `ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}`: This line uses the `-i` option to specify the SSH key for authentication.
   - `ssh ${REMOTE_USER}@${REMOTE_HOST} 'bash -s' < local_script.sh`: run local script on remote machine

### Running the Script:

1. Save the script to a file, for example, `update_remote_with_key.sh`.
2. Make the script executable: `chmod +x update_remote_with_key.sh`.
3. Run the script: `./update_remote_with_key.sh`.

### Security Note:

Using SSH keys is much more secure than passwords. Ensure your private key is kept secure and not exposed.