#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
SOCK=/run/mysqld/mysqld.sock

if [ ! -d /var/lib/mysql/mysql ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start a temporary, network-isolated instance to run the init SQL
    # against over the local socket. This is not the final PID 1 process:
    # it is stopped again before `exec mysqld` below takes over.
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket="$SOCK" &
    pid="$!"

    until mysqladmin --socket="$SOCK" ping >/dev/null 2>&1; do
        sleep 1
    done

    mysql --socket="$SOCK" -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin --socket="$SOCK" -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

exec mysqld --user=mysql --skip-networking=0 --port=3306 --bind-address=0.0.0.0