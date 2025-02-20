#!/bin/bash

# Prepreation
# sudo apt install tar rsync
# Copy from resources and start service
# sudo systemctl enable backup.timer
# sudo systemctl start backup.timer
# Manually test backup.service
# sudo systemctl start backup.service

# Variables
SOURCE_DIR="/srv/nfs4"
BACKUP_DIR="/home/mr/backup"
DATE=$(date +\%Y-\%m-\%d)
BACKUP_FILE="$BACKUP_DIR/backup-$DATE.tar.gz"

# Create backup directory if it does not exist
mkdir -p "$BACKUP_DIR"

# Create a compressed archive of the source directory
tar -czvf "$BACKUP_FILE" "$SOURCE_DIR"

# Optionally, you can use rsync to transfer the backup to another server/location
# RSYNC_USER="your_username"
# RSYNC_HOST="your_backup_server"
# RSYNC_DEST="/remote/backup/location"
# rsync -avz "$BACKUP_FILE" "$RSYNC_USER@$RSYNC_HOST:$RSYNC_DEST"

# Log the backup operation
echo "Backup of $SOURCE_DIR completed on $DATE" >> /var/log/backup.log

# To unpack or extract a tar file, type
# tar -xvf file.tar



