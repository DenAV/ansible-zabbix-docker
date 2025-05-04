#!/bin/bash

# Configuration
BACKUP_DIR="./zbx_env/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/zabbix_backup_${TIMESTAMP}.sql.gz"
ENV_VARS_DIRECTORY="./env_vars"
MYSQL_USER=$(cat "${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_USER")
MYSQL_PASSWORD=$(cat "${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_PASSWORD")
MYSQL_DATABASE="zabbix"
MYSQL_HOST="mysql-server"   # Docker Compose service name
MYSQL_PORT="3306"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Run backup using external MySQL image with mysqldump
echo "[INFO] Starting external mysqldump..."

docker run --rm \
  --network "$(docker network ls --filter name=zbx_database --format '{{.Name}}')" \
  -v "$(pwd)/zbx_env/backups:/backup" \
  mysql:8 \
  sh -c "exec mysqldump -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD --single-transaction --quick $MYSQL_DATABASE" \
  | gzip > "$BACKUP_FILE"

# Check result
if [ $? -eq 0 ]; then
    echo "[INFO] Backup successful: $BACKUP_FILE"
else
    echo "[ERROR] Backup failed!"
    exit 1
fi

# Cleanup old backups (older than 7 days)
find "$BACKUP_DIR" -type f -name "zabbix_backup_*.sql.gz" -mtime +7 -exec rm {} \;
