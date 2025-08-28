#!/bin/bash

set -e

. /run/secrets/wp_credentials.txt
. /run/secrets/db_credentials.txt

if [ ! -f /var/www/wordpress/wp-config-sample.php ]; then
	cp -r /usr/src/wordpress/* /var/www/wordpress/
fi

cd /var/www/wordpress

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="mariadb" \
		--dbcharset="utf8" \
		--skip-check \
		--allow-root
	echo "wp-config.php created successfully"
fi

echo "Waiting for MariaDB to be ready"

until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
	echo "MariaDB not ready yet"
	sleep 3
done

echo "MariaDB is ready"

if ! wp core is-installed --allow-root 2>/dev/null; then
	echo "installing wordpress..."
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="42 Inception by abakirca" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root
	echo "Creating normal user..."
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root
	echo "Wordpress installed successfully."
else
	echo "Wordpress is already installed."
fi

echo "Starting PHP-FPM"
exec php-fpm8.2 -F
