#!/bin/bash

# Prepreation
# sudo apt install tar rsync
# Copy from resources and start service
# sudo systemctl enable backup.timer
# sudo systemctl start backup.timer
# Manually test backup.service
# sudo systemctl start backup.service

# Variables (can be overridden from the environment, e.g. for a test run)
SOURCE_DIR="${SOURCE_DIR:-/srv/nfs4}"
BACKUP_DIR="${BACKUP_DIR:-/home/mr/backup}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"
# Number of backups to keep (including the new one); older backups are deleted
KEEP="${KEEP:-6}"
DATE=$(date +\%Y-\%m-\%d)
BACKUP_FILE="$BACKUP_DIR/backup-$DATE.tar.gz"

# Create backup directory if it does not exist
mkdir -p "$BACKUP_DIR"

# Create a compressed archive of the source directory.
# Write to a .part file first, so a failed or interrupted run never counts as a backup.
tar -czvf "$BACKUP_FILE.part" "$SOURCE_DIR"
RC=$?
# tar exit code 1 = some files changed while being read (normal on a live share), archive is valid
if [ "$RC" -gt 1 ] || [ ! -s "$BACKUP_FILE.part" ]; then
    rm -f "$BACKUP_FILE.part"
    echo "Backup of $SOURCE_DIR FAILED on $DATE (tar exit code $RC), no backups deleted" >> "$LOG_FILE"
    exit 1
fi
mv -f "$BACKUP_FILE.part" "$BACKUP_FILE"

# Optionally, you can use rsync to transfer the backup to another server/location
# RSYNC_USER="your_username"
# RSYNC_HOST="your_backup_server"
# RSYNC_DEST="/remote/backup/location"
# rsync -avz "$BACKUP_FILE" "$RSYNC_USER@$RSYNC_HOST:$RSYNC_DEST"

# Log the backup operation
echo "Backup of $SOURCE_DIR completed on $DATE" >> "$LOG_FILE"

# Retention: keep the newest $KEEP backups, delete the oldest.
# File names contain the date (backup-YYYY-MM-DD.tar.gz), so name order = age order.
if ! [ "$KEEP" -ge 1 ] 2>/dev/null; then
    echo "Invalid KEEP=$KEEP, no backups deleted" >> "$LOG_FILE"
    exit 1
fi
ls -1 "$BACKUP_DIR" | grep -E '^backup-[0-9]{4}-[0-9]{2}-[0-9]{2}\.tar\.gz$' | sort | head -n -"$KEEP" |
while read -r OLD; do
    rm -f "$BACKUP_DIR/$OLD" && echo "Deleted old backup $OLD (keep $KEEP)" >> "$LOG_FILE"
done

# To unpack or extract a tar file, type
# tar -xvf file.tar



