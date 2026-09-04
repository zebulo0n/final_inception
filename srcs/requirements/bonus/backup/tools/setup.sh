#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
STAMP=$(date +%Y%m%d_%H%M%S)

mysqldump -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" "${MYSQL_DATABASE}" \
    | gzip > "/backups/${MYSQL_DATABASE}_${STAMP}.sql.gz"

find /backups -name "*.sql.gz" -mtime +7 -delete