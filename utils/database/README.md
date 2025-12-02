# Zabbix Database Backup Utility Scripts

This directory contains utility scripts for backing up and validating Zabbix database backups.

## How to use backup with password file
```bash
chmod +x backup-zabbix-db-pwd.sh
./backup-zabbix-db-pwd.sh
``` 

## How to use backup with the .my.cnf credentials file

```bash
chmod +x backup-zabbix-db-cfn.sh
./backup-zabbix-db-cfn.sh
``` 

## How to validate Zabbix database backup

```bash
chmod +x validate-zabbix-backup.sh
./validate-zabbix-backup.sh ./zbx_env/backups/zabbix_backup_2025-05-04_16-15-00.sql.gz
```