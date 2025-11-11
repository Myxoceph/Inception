# ARG: Define build-time variable (can be overridden during build)
# RELEASE=bookworm: Sets default value to 'bookworm' (Debian 12 codename)
ARG RELEASE=bookworm

# FROM: Specify base image for this Docker image
# debian:${RELEASE}: Use official Debian image with version from RELEASE variable
# This creates the foundation layer for our MariaDB container
FROM debian:${RELEASE}

# RUN: Execute commands during image build
# apt-get update: Updates package index from Debian repositories
# &&: Logical AND operator - only run next command if previous succeeds
# apt-get install -y: Install packages with automatic 'yes' to prompts
# mariadb-server: MariaDB database server package
# &&: Chain another command
# rm -rf /var/lib/apt/lists/*: Remove package lists to reduce image size
# This is a Docker best practice - clean up apt cache in same layer
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# RUN: Create directory and set permissions for MariaDB socket file
# mkdir -p: Create directory, including parent directories if needed
# /run/mysqld: Directory where MySQL/MariaDB stores runtime socket file
# &&: Chain next command
# chown -R: Change ownership recursively
# mysql:mysql: Set owner:group to mysql user and mysql group
# /var/run/mysqld: Directory to change ownership of
# &&: Chain next command
# chmod 777: Set permissions to rwxrwxrwx (read/write/execute for all)
# This ensures MariaDB can create its socket file in this directory
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /var/run/mysqld && chmod 777 /var/run/mysqld

# COPY: Copy files from host to container during build
# tools/mariadb.sh: Source path (relative to build context)
# /mariadb.sh: Destination path in container filesystem
# This copies the initialization script into the container
COPY tools/mariadb.sh /mariadb.sh

# RUN: Make the script executable
# chmod +x: Add execute permission
# /mariadb.sh: Path to the script we just copied
RUN chmod +x /mariadb.sh

# RUN: Modify MariaDB configuration to allow remote connections
# sed: Stream editor for text manipulation
# -i: Edit file in-place
# 's/pattern/replacement/': Substitute pattern with replacement
# bind-address\s*=\s*127.0.0.1: Pattern to find (bind address set to localhost)
# \s*: Matches zero or more whitespace characters
# bind-address = 0.0.0.0: Replacement (bind to all network interfaces)
# /etc/mysql/mariadb.conf.d/50-server.cnf: Configuration file to modify
# This allows MariaDB to accept connections from other containers
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# ENTRYPOINT: Define the main process that runs when container starts
# ["/mariadb.sh"]: JSON array format (exec form, preferred over shell form)
# This runs our initialization script which starts MariaDB
# ENTRYPOINT cannot be overridden by docker run arguments (unlike CMD)
ENTRYPOINT ["/mariadb.sh"]
