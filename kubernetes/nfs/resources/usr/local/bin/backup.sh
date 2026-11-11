#!/bin/bash

# Prepreation
# sudo apt install tar rsync
# Copy from resources and start service
# sudo systemctl enable backup.timer
# sudo systemctl start backup.timer
# Manually test backup.service
# sudo systemctl start backup.service

# Variables (can be overridden from the environment, e.g. for a test run)
# Every directory directly below SOURCE_DIR is one application and gets its own backup.
SOURCE_DIR="${SOURCE_DIR:-/srv/nfs4/homes/mr}"
BACKUP_DIR="${BACKUP_DIR:-/home/mr/backup}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"
# Number of backups to keep per application (including the new one); older backups are deleted
KEEP="${KEEP:-6}"
# Directories that are not backed up: space separated list of <application>:<path below the application directory>.
# The directory itself stays in the backup (empty), only its content is left out. EXCLUDES="" = no exclude.
EXCLUDES="${EXCLUDES-teddycloud:library}"
DATE=$(date +\%Y-\%m-\%d)

log() {
    echo "$1" >> "$LOG_FILE"
}

# Backup of one application: $BACKUP_DIR/<application>/<application>-YYYY-MM-DD.tar.gz
backup_app() {
    local APP="$1"
    local APP_BACKUP_DIR="$BACKUP_DIR/$APP"
    local BACKUP_FILE="$APP_BACKUP_DIR/$APP-$DATE.tar.gz"
    local EXCLUDE_ARGS=()
    local EXCLUDED=""
    local ENTRY EXCLUDE_PATH RC OLD

    for ENTRY in $EXCLUDES; do
        if [ "${ENTRY%%:*}" = "$APP" ]; then
            EXCLUDE_PATH="${ENTRY#*:}"
            EXCLUDE_PATH="${EXCLUDE_PATH%/}"
            EXCLUDE_ARGS+=(--anchored "--exclude=$APP/$EXCLUDE_PATH/*")
            EXCLUDED="$EXCLUDED $EXCLUDE_PATH"
        fi
    done

    # Create backup directory if it does not exist
    if ! mkdir -p "$APP_BACKUP_DIR"; then
        log "Backup of $SOURCE_DIR/$APP FAILED on $DATE (cannot create $APP_BACKUP_DIR), no backups deleted"
        return 1
    fi

    # Create a compressed archive of the application directory (paths in the archive start with <application>/).
    # Write to a .part file first, so a failed or interrupted run never counts as a backup.
    tar -C "$SOURCE_DIR" "${EXCLUDE_ARGS[@]}" -czvf "$BACKUP_FILE.part" "$APP"
    RC=$?
    # tar exit code 1 = some files changed while being read (normal on a live share), archive is valid
    if [ "$RC" -gt 1 ] || [ ! -s "$BACKUP_FILE.part" ]; then
        rm -f "$BACKUP_FILE.part"
        log "Backup of $SOURCE_DIR/$APP FAILED on $DATE (tar exit code $RC), no backups deleted"
        return 1
    fi
    if ! mv -f "$BACKUP_FILE.part" "$BACKUP_FILE"; then
        rm -f "$BACKUP_FILE.part"
        log "Backup of $SOURCE_DIR/$APP FAILED on $DATE (cannot write $BACKUP_FILE), no backups deleted"
        return 1
    fi

    # Log the backup operation
    log "Backup of $SOURCE_DIR/$APP completed on $DATE${EXCLUDED:+ (content not included:$EXCLUDED)}"

    # Retention: keep the newest $KEEP backups of this application, delete the oldest.
    # File names contain the date (<application>-YYYY-MM-DD.tar.gz), so name order = age order.
    if [ "$KEEP_VALID" != 1 ]; then
        return 1
    fi
    printf '%s\n' "$APP_BACKUP_DIR/$APP"-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].tar.gz | sort | head -n -"$KEEP" |
    while read -r OLD; do
        [ -f "$OLD" ] && rm -f "$OLD" && log "Deleted old backup $APP/$(basename "$OLD") (keep $KEEP)"
    done
    return 0
}

KEEP_VALID=1
if ! [ "$KEEP" -ge 1 ] 2>/dev/null; then
    KEEP_VALID=0
    log "Invalid KEEP=$KEEP, no backups deleted"
fi

# One backup per application directory. A failed application does not stop the others.
FAILED=0
COUNT=0
for APP_DIR in "$SOURCE_DIR"/*; do
    [ -e "$APP_DIR" ] || [ -L "$APP_DIR" ] || continue
    if [ -L "$APP_DIR" ] || [ ! -d "$APP_DIR" ]; then
        log "Skipped $APP_DIR on $DATE (not a directory, not part of any application backup)"
        continue
    fi
    COUNT=$((COUNT + 1))
    backup_app "$(basename "$APP_DIR")" || FAILED=1
done

if [ "$COUNT" -eq 0 ]; then
    log "Backup FAILED on $DATE (no application directory in $SOURCE_DIR), no backups deleted"
    exit 1
fi

# Optionally, you can use rsync to transfer the backups to another server/location
# RSYNC_USER="your_username"
# RSYNC_HOST="your_backup_server"
# RSYNC_DEST="/remote/backup/location"
# rsync -avz "$BACKUP_DIR/" "$RSYNC_USER@$RSYNC_HOST:$RSYNC_DEST"

# To unpack or extract the backup of one application, type
# tar -xzvf <application>-YYYY-MM-DD.tar.gz -C /srv/nfs4/homes/mr

# Exit code 1 if at least one application failed (the other applications are still backed up)
exit "$FAILED"
