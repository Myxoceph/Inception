# Shebang: Specifies which interpreter should execute this script
# !/bin/bash: Use bash shell to run this script
#!/bin/bash

# set: Change shell options
# -e: Exit immediately if any command returns non-zero exit status (error)
# This ensures script fails fast on errors instead of continuing
set -e

# . (dot command): Source/execute commands from a file in current shell
# /run/secrets/db_credentials.txt: File containing database credentials
# This loads environment variables like MYSQL_DATABASE, MYSQL_USER, etc.
# Variables defined in that file become available in this script
. /run/secrets/db_credentials.txt

# if: Conditional statement
# [ ! -d "/var/lib/mysql/mysql" ]: Test condition
# -d: Check if path exists and is a directory
# !: Negate the condition (true if directory does NOT exist)
# /var/lib/mysql/mysql: System database directory (exists if DB initialized)
# then: Execute following commands if condition is true
if [ ! -d "/var/lib/mysql/mysql" ]; then
	# echo: Print message to stdout
	echo "Initializing MariaDB database..."
	# mariadb-install-db: Initialize MariaDB data directory
	# --user=mysql: Run as mysql user (for security)
	# --datadir=/var/lib/mysql: Specify where to create database files
	# This creates the initial system tables and database structure
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# fi: End of if statement
fi

# Commented out code block (originally checked if database already exists)
# This was likely removed because the SQL initialization handles this with IF NOT EXISTS
# DATABASE_EXIST=false

# if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
# 	echo "Database ${MYSQL_DATABASE} already exists."
# 	DATABASE_EXIST=true
# else
# 	echo "Database ${MYSQL_DATABASE} does not exist. Creating..."
# fi

# if [ "$DATABASE_EXIST" = false ]; then
# 	echo "Setting up database..."

	# cat: Concatenate and output content
	# <<EOF: Here-document - allows multi-line string input
	# Everything between <<EOF and EOF is treated as input
	# >: Redirect output
	# /tmp/init.sql: Write SQL commands to this temporary file
	# This creates an SQL initialization script that will run when MariaDB starts
	cat <<EOF > /tmp/init.sql
# SQL: CREATE DATABASE IF NOT EXISTS - create database if it doesn't exist
# ${MYSQL_DATABASE}: Variable expansion - replaced with actual database name
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# SQL: CREATE USER IF NOT EXISTS - create database user if doesn't exist
# '${MYSQL_USER}'@'%': Username @ host pattern
# '%': Wildcard - user can connect from any host (necessary for Docker networking)
# IDENTIFIED BY: Set password for the user
# '${MYSQL_PASSWORD}': Password from environment variable
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# SQL: GRANT ALL PRIVILEGES - give user full access to specific database
# ${MYSQL_DATABASE}.*: All tables in the specified database
# TO '${MYSQL_USER}'@'%': Grant to this user from any host
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# SQL: CREATE another user with admin privileges
# ${MYSQL_ADMIN_USER}: Admin username from environment
# ${MYSQL_ADMIN_PASSWORD}: Admin password from environment
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
# SQL: GRANT ALL PRIVILEGES on all databases (*.*) to admin user
# *.* means all databases and all tables - full superuser access
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%';
# SQL: ALTER USER - change root user password
# 'root'@'localhost': Root user accessible only from localhost (security)
# IDENTIFIED BY: Set new password
# ${MYSQL_ROOT_PASSWORD}: Root password from environment
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# SQL: FLUSH PRIVILEGES - reload the grant tables
# Makes privilege changes take effect immediately without restart
FLUSH PRIVILEGES;
# EOF: End of here-document marker
EOF

# Commented out closing brace from previous if statement
# fi

# echo: Print informational message
echo "Starting MariaDB server in foreground..."

# exec: Replace current shell process with the command that follows
# This makes mysqld_safe the main process (PID 1) in the container
# Important for proper signal handling (SIGTERM, etc.)
# mysqld_safe: Wrapper script that starts mysqld with monitoring/restart capability
# --user=mysql: Run MariaDB server as mysql user (security best practice)
# --init-file=/tmp/init.sql: Execute SQL file after server starts
# This initializes database, creates users, and sets permissions
exec mysqld_safe --user=mysql --init-file=/tmp/init.sql
