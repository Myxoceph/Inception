# ARG: Build-time variable that can be overridden during build
# RELEASE=bookworm: Default Debian version (Debian 12)
ARG RELEASE=bookworm

# FROM: Base image for this container
# debian:${RELEASE}: Official Debian image using version from ARG
FROM debian:${RELEASE}

# RUN: Execute commands during image build
# apt-get update: Update package repository index
# &&: Chain commands (only run if previous succeeds)
# apt-get install -y: Install packages with automatic 'yes' to prompts
# php: PHP interpreter
# php-fpm: PHP FastCGI Process Manager (for serving PHP)
# php-cli: PHP command line interface
# php-mysqli: PHP extension for MySQL/MariaDB connectivity
# wget: Command-line utility for downloading files
# curl: Tool for transferring data with URLs
# tar: Archive utility for extracting compressed files
# mariadb-client: Client tools for connecting to MariaDB
# &&: Chain cleanup command
# rm -rf /var/lib/apt/lists/*: Remove package lists to reduce image size
RUN apt-get update && apt-get install -y \
   php php-fpm php-cli php-mysqli \
   wget curl tar mariadb-client \
   && rm -rf /var/lib/apt/lists/*

# RUN: Modify PHP-FPM configuration
# sed: Stream editor for text manipulation
# -i: Edit file in-place
# 's/pattern/replacement/g': Substitute pattern with replacement globally
# listen =.*: Pattern matching 'listen =' followed by anything
# listen = 0.0.0.0:9000: Replacement - listen on all interfaces on port 9000
# /etc/php/8.2/fpm/pool.d/www.conf: PHP-FPM pool configuration file
# This allows PHP-FPM to accept connections from other containers (nginx)
RUN sed -i 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/8.2/fpm/pool.d/www.conf

# RUN: Create directories, download and extract WordPress
# mkdir -p: Create directories (no error if exists)
# /usr/src/wordpress: Temporary location for WordPress source
# /var/www/wordpress: Final location where WordPress will be installed
# /run/php: Runtime directory for PHP-FPM socket files
# &&: Chain next command
# wget: Download file
# https://wordpress.org/latest.tar.gz: WordPress latest version archive
# -O /tmp/wordpress.tar.gz: Save as this filename
# &&: Chain next command
# tar: Extract archive
# -xzf: Extract (x), gzip compressed (z), from file (f)
# /tmp/wordpress.tar.gz: Archive to extract
# -C /usr/src/: Extract into this directory
# &&: Chain cleanup
# rm -f: Remove file, force (no error if doesn't exist)
# /tmp/wordpress.tar.gz: Clean up downloaded archive
RUN mkdir -p /usr/src/wordpress /var/www/wordpress /run/php \
   && wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
   && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/ \
   && rm -f /tmp/wordpress.tar.gz

# Comment indicating next section
# Install WP-CLI
# RUN: Download and install WordPress Command Line Interface
# curl: Transfer data from URL
# -o /usr/local/bin/wp: Save output to this file
# https://raw.githubusercontent.com/.../wp-cli.phar: WP-CLI PHP archive
# &&: Chain next command
# chmod +x: Add execute permission
# /usr/local/bin/wp: Make WP-CLI executable
# WP-CLI is a command-line tool for managing WordPress installations
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
   && chmod +x /usr/local/bin/wp

# COPY: Copy WordPress initialization script from host to container
# tools/wordpress.sh: Source file in build context
# /wordpress.sh: Destination in container root
COPY tools/wordpress.sh /wordpress.sh

# RUN: Make the WordPress initialization script executable
# chmod +x: Add execute permission
# /wordpress.sh: Script that will configure and start WordPress
RUN chmod +x /wordpress.sh

# ENTRYPOINT: Command that runs when container starts
# ["/wordpress.sh"]: JSON array format (exec form)
# Executes the WordPress initialization script as main process
ENTRYPOINT ["/wordpress.sh"]
