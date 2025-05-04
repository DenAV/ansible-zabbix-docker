#!/bin/bash

# Configuration
BACKUP_DIR="./zbx_env/backups"
ENV_VARS_DIRECTORY="./env_vars"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/zabbix_backup_${TIMESTAMP}.sql.gz"
MYSQL_USER=$(cat "${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_USER")
MYSQL_PASSWORD=$(cat "${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_PASSWORD")
MYSQL_DATABASE="zabbix"
MYSQL_HOST="mysql-server"
MYSQL_PORT="3306"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create temporary my.cnf with credentials
MY_CNF_FILE=$(mktemp)
cat > "$MY_CNF_FILE" <<EOF
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
host=$MYSQL_HOST
port=$MYSQL_PORT
EOF

chmod 600 "$MY_CNF_FILE"

# Perform mysqldump using the .my.cnf credentials file
echo "[INFO] Starting secure mysqldump with credentials file..."

docker run --rm \
  --network "$(docker network ls --filter name=zbx_database --format '{{.Name}}')" \
  -v "$MY_CNF_FILE:/root/.my.cnf:ro" \
  mysql:8 \
  sh -c "exec mysqldump --defaults-extra-file=/root/.my.cnf --no-tablespaces --single-transaction --quick $MYSQL_DATABASE" \
  | gzip > "$BACKUP_FILE"

# Check result
if [ $? -eq 0 ]; then
    echo "[INFO] Backup successful: $BACKUP_FILE"
else
    echo "[ERROR] Backup failed!"
    rm -f "$MY_CNF_FILE"
    exit 1
fi

# Clean up temporary file
rm -f "$MY_CNF_FILE"

# Remove old backups (older than 7 days)
find "$BACKUP_DIR" -type f -name "zabbix_backup_*.sql.gz" -mtime +7 -exec rm {} \;
