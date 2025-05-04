# Utils for Database

## How to use backup with password
```bash
chmod +x backup-zabbix-db-pwd.sh
./backup-zabbix-db-pwd.sh
``` 

## How to use backup with cfn file
```bash
chmod +x backup-zabbix-db-cfn.sh
./backup-zabbix-db-cfn.sh
``` 

## How to use validate:

```bash
chmod +x validate-zabbix-backup.sh
./validate-zabbix-backup.sh ./zbx_env/backups/zabbix_backup_2025-05-04_16-15-00.sql.gz
```