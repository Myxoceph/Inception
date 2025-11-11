# Shebang: Specifies bash interpreter for this script
#!/bin/bash

# set: Modify shell options
# -e: Exit immediately if any command returns non-zero exit status
# Ensures script stops on first error rather than continuing
set -e

# . (dot command): Source file in current shell context
# /run/secrets/wp_credentials.txt: Load WordPress credentials
# This file contains WP_ADMIN_USER, WP_ADMIN_PASSWORD, WP_USER, etc.
. /run/secrets/wp_credentials.txt
# . (dot command): Source database credentials file
# /run/secrets/db_credentials.txt: Load database connection info
# This file contains MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, etc.
. /run/secrets/db_credentials.txt

# if: Conditional statement
# [ ! -f /path ]: Test if file does NOT exist
# -f: Check if path exists and is a regular file
# !: Negate the condition
# /var/www/wordpress/wp-config-sample.php: WordPress sample config file
# This checks if WordPress files have been copied yet
if [ ! -f /var/www/wordpress/wp-config-sample.php ]; then
	# cp: Copy command
	# -r: Recursive - copy directories and their contents
	# /usr/src/wordpress/*: Source - all files in WordPress source directory
	# /var/www/wordpress/: Destination - final WordPress installation directory
	# This copies WordPress files to the persistent volume
	cp -r /usr/src/wordpress/* /var/www/wordpress/
# fi: End if statement
fi

# cd: Change directory
# /var/www/wordpress: Move into WordPress installation directory
# All subsequent WP-CLI commands will execute in this context
cd /var/www/wordpress

# if: Check if WordPress configuration file exists
# [ ! -f "/var/www/wordpress/wp-config.php" ]: Test if wp-config.php does NOT exist
# -f: Check if it's a regular file
# !: Negate condition
# wp-config.php: Main WordPress configuration file
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
	# echo: Print informational message
	echo "Creating wp-config.php..."
	# wp: WP-CLI command
	# config create: Generate wp-config.php file
	# --dbname: Database name parameter
	# "${MYSQL_DATABASE}": Variable from db_credentials.txt
	# --dbuser: Database username
	# "${MYSQL_USER}": Variable from db_credentials.txt
	# --dbpass: Database password
	# "${MYSQL_PASSWORD}": Variable from db_credentials.txt
	# --dbhost: Database host (container name in Docker network)
	# "mariadb": MariaDB container hostname
	# --dbcharset: Character set for database
	# "utf8": UTF-8 encoding (standard for WordPress)
	# --skip-check: Don't check if database connection works (we'll wait later)
	# --allow-root: Allow running as root user (required in Docker)
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="mariadb" \
		--dbcharset="utf8" \
		--skip-check \
		--allow-root
	# echo: Print success message
	echo "wp-config.php created successfully"
# fi: End if statement
fi

# echo: Print informational message
echo "Waiting for MariaDB to be ready"

# until: Loop until condition becomes true
# mysql: MariaDB client command
# -h mariadb: Connect to host named 'mariadb' (container name)
# -u"${MYSQL_USER}": Username (note: no space between -u and value)
# -p"${MYSQL_PASSWORD}": Password (note: no space between -p and value)
# -e "SELECT 1": Execute SQL query (simple test query)
# >/dev/null: Redirect stdout to null device (suppress output)
# 2>&1: Redirect stderr to stdout (also suppressed)
# This keeps trying to connect until MariaDB is ready to accept connections
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
	# echo: Print waiting message
	echo "MariaDB not ready yet"
	# sleep: Pause execution
	# 3: Wait for 3 seconds before trying again
	sleep 3
# done: End until loop
done

# echo: Print success message
echo "MariaDB is ready"

# if: Check if WordPress is already installed
# !: Negate the following condition
# wp: WP-CLI command
# core is-installed: Check if WordPress database tables exist
# --allow-root: Allow running as root user
# 2>/dev/null: Redirect stderr to null (suppress error messages)
# The command returns 0 (true) if installed, non-zero if not
# ! negates it: true if NOT installed
if ! wp core is-installed --allow-root 2>/dev/null; then
	# echo: Print informational message
	echo "installing wordpress..."
	# wp: WP-CLI command
	# core install: Install WordPress (create database tables, set up site)
	# --url: Site URL parameter
	# "https://${DOMAIN_NAME}": Site URL using DOMAIN_NAME variable from .env
	# --title: Site title displayed in browser and admin
	# "42 Inception by abakirca": Your project title
	# --admin_user: WordPress administrator username
	# "${WP_ADMIN_USER}": Variable from wp_credentials.txt
	# --admin_password: WordPress administrator password
	# "${WP_ADMIN_PASSWORD}": Variable from wp_credentials.txt
	# --admin_email: WordPress administrator email address
	# "${WP_ADMIN_EMAIL}": Variable from wp_credentials.txt
	# --allow-root: Allow running as root user in Docker
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="42 Inception by abakirca" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root
	# echo: Print informational message
	echo "Creating normal user..."
	# wp: WP-CLI command
	# user create: Create a new WordPress user
	# "${WP_USER}": Username from wp_credentials.txt
	# "${WP_USER_EMAIL}": User's email address
	# --user_pass: Password for the new user
	# "${WP_USER_PASSWORD}": Password from wp_credentials.txt
	# --role: User's role in WordPress
	# author: Role that can create and publish their own posts
	# --allow-root: Allow running as root
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root
	# echo: Print success message
	echo "Wordpress installed successfully."
# else: If WordPress is already installed
else
	# echo: Print informational message
	echo "Wordpress is already installed."
# fi: End if statement
fi

# echo: Print informational message
echo "Starting PHP-FPM"
# exec: Replace current shell with the following command
# This makes PHP-FPM the main process (PID 1) in container
# Ensures proper signal handling for container stop/restart
# php-fpm8.2: PHP FastCGI Process Manager version 8.2
# -F: Run in foreground (don't daemonize)
# Critical for Docker - container stays alive while PHP-FPM runs
exec php-fpm8.2 -F
