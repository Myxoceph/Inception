#!/bin/bash

mkdir -p /run/mysqld

chown mysql:mysql /run/mysqld

# Check if MySQL data directory exists and is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

DATABASE_EXIST=false

if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Database ${MYSQL_DATABASE} already exists."
	DATABASE_EXIST=true
else
	echo "Database ${MYSQL_DATABASE} does not exist. Creating..."
fi

echo "Starting MariaDB server..."

mysqld_safe --user=mysql &

until mysqladmin ping --silent; do
	echo "Waiting for MariaDB to start..."
	sleep 2
done

echo "MariaDB server is up and running."

if [ "$DATABASE_EXIST" = false ]; then
	echo "Setting up database..."

	mysql -u root <<-EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	echo "Database setup complete."
fi

echo "Stopping temporary MariaDB server..."

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "Starting MariaDB server in foreground..."

exec mysqld_safe --user=mysql
