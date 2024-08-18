#!/bin/bash

# Configuration
MYSQL_USER="your_mysql_user"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DATABASE="your_database_name"
BACKUP_DIR="/path/to/backup"
DATE=$(date +%F)
BACKUP_FILE="${BACKUP_DIR}/${MYSQL_DATABASE}_${DATE}.sql"
ZIP_FILE="${BACKUP_FILE}.zip"
TELEGRAM_TOKEN="your_telegram_bot_token"
TELEGRAM_CHAT_ID="your_telegram_channel_id"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform MySQL backup
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > "$BACKUP_FILE"

# Check if backup was successful
if [ $? -ne 0 ]; then
    echo "MySQL backup failed!"
    exit 1
fi

# Compress the backup file
zip "$ZIP_FILE" "$BACKUP_FILE"

# Check if zip was successful
if [ $? -ne 0 ]; then
    echo "Failed to compress backup!"
    exit 1
fi

# Send the backup file to Telegram channel
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" \
    -F document=@"${ZIP_FILE}"

# Check if the file was sent successfully
if [ $? -ne 0 ]; then
    echo "Failed to send backup to Telegram!"
    exit 1
fi

# Clean up
rm "$BACKUP_FILE" "$ZIP_FILE"

echo "Backup and upload successful!"
