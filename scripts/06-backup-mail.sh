#!/bin/bash

# ==========================================================
# Self-Hosted Mail Server - Mail Backup Script
# ==========================================================
# Creates timestamped backups of all Maildir folders.
# Can be used with cron for automated backups.
# ==========================================================

set -e

# ====== CONFIGURATION ======
MAIL_ROOT="/home"               # Base directory containing user home directories
BACKUP_DIR="/var/backups/mail" # Directory to store backups
RETENTION=7                     # Number of backups to keep

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/mail_backup_$TIMESTAMP.tar.gz"

echo "Starting mail backup at $TIMESTAMP"

# Create backup directory if missing
if [ ! -d "$BACKUP_DIR" ]; then
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown $(whoami):$(whoami) "$BACKUP_DIR"
fi

# Find all Maildir folders and archive them
echo "Archiving Maildir folders from $MAIL_ROOT..."
sudo tar -czf "$BACKUP_FILE" --exclude="$BACKUP_DIR" $(find "$MAIL_ROOT" -type d -name "Maildir")

# Set permissions
sudo chmod 600 "$BACKUP_FILE"
sudo chown $(whoami):$(whoami) "$BACKUP_FILE"

echo "Backup completed successfully: $BACKUP_FILE"

# ====== Cleanup old backups ======
echo "Cleaning up old backups, keeping last $RETENTION backups..."
ls -1tr "$BACKUP_DIR"/mail_backup_*.tar.gz | head -n -$RETENTION | xargs -r rm -f

echo "Backup rotation completed."