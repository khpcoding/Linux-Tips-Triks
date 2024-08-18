# MySQL Backup and Telegram Upload Script

This bash script performs a daily backup of a MySQL database, compresses the backup into a ZIP file, and sends it to a Telegram channel.

## Script Overview

The script performs the following tasks:

- Creates a backup of a MySQL database.
- Compresses the backup file into a ZIP format.
- Sends the ZIP file to a specified Telegram channel.
- Cleans up the backup files after sending.

## Configuration

Before running the script, you need to configure the following variables:

- `MYSQL_USER`: Your MySQL username.
- `MYSQL_PASSWORD`: Your MySQL password.
- `MYSQL_DATABASE`: The name of the database you want to back up.
- `BACKUP_DIR`: Directory where the backup will be stored.
- `TELEGRAM_TOKEN`: Your Telegram bot token.
- `TELEGRAM_CHAT_ID`: The chat ID of the Telegram channel where the backup will be sent.

### Example Configuration
```bash
# Configuration
MYSQL_USER="root"
MYSQL_PASSWORD="your_password"
MYSQL_DATABASE="my_database"
BACKUP_DIR="/path/to/backup"
TELEGRAM_TOKEN="123456789:ABCDEF_GHIJKL_MNOPQR_STUVWXYZ"
TELEGRAM_CHAT_ID="@your_channel"
```
## Usage
1. Save the Script

Save the script to a file, for example Auto_Backup.sh.

2. Make the Script Executable

Run the following command to make the script executable:

``` bash
chmod +x backup_and_send.sh
```
3. Run the Script

Execute the script manually or set it up as a cron job for automatic daily backups:

```bash
./Auto_Backup.sh
```
4. Set Up Automatic Backups

To schedule the script to run daily, add a cron job:

```bash
crontab -e
```
Add the following line to run the script daily at 2 AM:

```bash
0 2 * * * /path/to/backup_and_send.sh
```





