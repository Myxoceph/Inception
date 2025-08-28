#!/bin/bash

set -e

. /run/secrets/db_credentials.txt

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# DATABASE_EXIST=false

# if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
# 	echo "Database ${MYSQL_DATABASE} already exists."
# 	DATABASE_EXIST=true
# else
# 	echo "Database ${MYSQL_DATABASE} does not exist. Creating..."
# fi

# if [ "$DATABASE_EXIST" = false ]; then
# 	echo "Setting up database..."

	cat <<EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# fi

echo "Starting MariaDB server in foreground..."

exec mysqld_safe --user=mysql --init-file=/tmp/init.sql
