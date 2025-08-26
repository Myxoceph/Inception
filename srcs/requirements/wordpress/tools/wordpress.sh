#!/bin/bash

# if [ ! -f "/var/www/wordpress/wp-config-sample.php" ]; then
# 	echo "Wordpress not found, downloading..."
# 	wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
# 	tar -xzf /tmp/wordpress.tar.gz -C /tmp
# 	cp -r /tmp/wordpress/* /var/www/wordpress/
# 	rm -rf /tmp/wordpress.tar.gz /tmp/wordpress

# 	echo "Wordpress downloaded and extracted."
# else
# 	echo "Wordpress already installed."
# fi

# config create komutuna bakilacak

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
	sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/wordpress/wp-config.php
	sed -i "s/username_here/${MYSQL_USER}/" /var/www/wordpress/wp-config.php
	sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/wordpress/wp-config.php
	sed -i "s/localhost/mariadb/" /var/www/wordpress/wp-config.php

	echo "wp-config.php created successfully."
fi

echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
	echo "MariaDB not ready yet, waiting..."
	sleep 3
done
echo "MariaDB is ready."

if [ ! -f "/usr/local/bin/wp" ]; then
	echo "Downloading WP-CLI..."
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar
	chmod +x /tmp/wp-cli.phar
	mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

cd /var/www/wordpress
echo "Changed directory to $(pwd)"

if ! wp core is-installed --allow-root 2>/dev/null; then
	echo "installing wordpress..."
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="42 Inception" \
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

chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
