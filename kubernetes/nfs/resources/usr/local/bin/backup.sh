#!/bin/bash

# Prepreation
# sudo apt install tar rsync
# Copy from resources and start service
# sudo systemctl enable backup.timer
# sudo systemctl start backup.timer
# Manually test backup.service
# sudo systemctl start backup.service

# Why the staging copy: SOURCE_DIR is exported over NFS. GNU tar opens every file with O_NONBLOCK,
# and that open fails with "Cannot open: Resource temporarily unavailable" (EAGAIN) while an NFS
# client holds a delegation on the file. Exactly the files the apps keep in use (openHAB rrd4j,
# Prometheus, Grafana) were therefore missing from every archive, and the script still logged
# "completed". rsync opens files normally (blocking), so nfsd recalls the delegation and the copy
# succeeds; tar then archives the local copy.

set -u

# Variables (SOURCE_DIR, BACKUP_DIR and LOG_FILE can be overridden from the environment for a test run)
SOURCE_DIR="${SOURCE_DIR:-/srv/nfs4}"
BACKUP_DIR="${BACKUP_DIR:-/home/mr/backup}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"
DATE=$(date +\%Y-\%m-\%d)
BACKUP_FILE="$BACKUP_DIR/backup-$DATE.tar.gz"
STAGING_DIR="$BACKUP_DIR/.staging"

fail() {
    echo "Backup of $SOURCE_DIR FAILED on $DATE: $1" | tee -a "$LOG_FILE" >&2
    exit 1
}

[ -d "$SOURCE_DIR" ] || fail "source directory not found"

# Create backup directory if it does not exist
mkdir -p "$BACKUP_DIR" || fail "cannot create $BACKUP_DIR"

# The staging copy is removed on every exit, also after a failure
trap 'rm -rf "$STAGING_DIR"' EXIT

# Copy the source to the local staging directory. The source path is kept below the staging
# directory, so the archive members stay "srv/nfs4/..." as in the earlier backups.
mkdir -p "$STAGING_DIR$SOURCE_DIR" || fail "cannot create $STAGING_DIR"
rsync -a --delete "$SOURCE_DIR/" "$STAGING_DIR$SOURCE_DIR/"
rsync_rc=$?
# 0 = complete; 24 = files vanished during the copy (normal for live application data);
# 23 = some files could not be copied: archive what was copied, then report the run as failed
if [ "$rsync_rc" -ne 0 ] && [ "$rsync_rc" -ne 23 ] && [ "$rsync_rc" -ne 24 ]; then
    fail "rsync exit code $rsync_rc"
fi

# Create a compressed archive of the staging copy. A partial archive is deleted, so that no
# incomplete file looks like a valid backup.
tar -czvf "$BACKUP_FILE" -C "$STAGING_DIR" "${SOURCE_DIR#/}"
tar_rc=$?
if [ "$tar_rc" -ne 0 ]; then
    rm -f "$BACKUP_FILE"
    fail "tar exit code $tar_rc"
fi
if [ "$rsync_rc" -eq 23 ]; then
    fail "incomplete, rsync could not copy some files (exit code 23, see the journal); archive $BACKUP_FILE"
fi

# Optionally, you can use rsync to transfer the backup to another server/location
# RSYNC_USER="your_username"
# RSYNC_HOST="your_backup_server"
# RSYNC_DEST="/remote/backup/location"
# rsync -avz "$BACKUP_FILE" "$RSYNC_USER@$RSYNC_HOST:$RSYNC_DEST"

# Log the backup operation
echo "Backup of $SOURCE_DIR completed on $DATE" >> "$LOG_FILE"

# To unpack or extract a tar file, type
# tar -xvf file.tar
