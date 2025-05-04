#!/bin/bash

# === Configuration ===
BACKUP_FILE="$1"

# === Functions ===

print_usage() {
    echo "Usage: $0 path/to/zabbix_backup_*.sql.gz"
    exit 1
}

# === Input validation ===

if [ -z "$BACKUP_FILE" ]; then
    echo "[ERROR] Backup file not specified."
    print_usage
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "[ERROR] File not found: $BACKUP_FILE"
    exit 1
fi

# === Step 1: Gzip integrity check ===
echo "[INFO] Checking gzip integrity..."
if gzip -t "$BACKUP_FILE"; then
    echo "[INFO] Gzip archive is valid."
else
    echo "[ERROR] Gzip archive is corrupted!"
    exit 1
fi

# === Step 2: Print SQL dump header ===
echo "[INFO] Showing SQL dump header:"
echo "----------------------------------------"
zcat "$BACKUP_FILE" | head -n 20
echo "----------------------------------------"

echo "[INFO] Header check complete."
