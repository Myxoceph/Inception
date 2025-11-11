# ARG: Define build-time variable that can be overridden
# RELEASE=bookworm: Default value is 'bookworm' (Debian 12)
ARG RELEASE=bookworm

# FROM: Specify base image for this Docker image
# debian:${RELEASE}: Use official Debian image with version from ARG variable
FROM debian:${RELEASE}

# RUN: Execute commands during image build
# apt-get update: Update package index from repositories
# &&: Chain commands - only run next if previous succeeds
# apt-get install -y: Install packages with automatic 'yes'
# nginx: Web server and reverse proxy
# openssl: Toolkit for SSL/TLS certificate generation and management
# &&: Chain another command
# rm -rf /var/lib/apt/lists/*: Remove package cache to reduce image size
# This is Docker best practice - clean cache in same layer where packages installed
RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

# COPY: Copy file from build context (host) to container
# tools/nginx.sh: Source file containing SSL certificate generation script
# /nginx.sh: Destination path in container
COPY tools/nginx.sh /nginx.sh

# RUN: Execute commands during build
# chmod +x: Add execute permission to the script
# /nginx.sh: Path to script we just copied
# &&: Chain next command
# /nginx.sh: Execute the script immediately during build
# This runs the SSL certificate generation before container starts
RUN chmod +x /nginx.sh && /nginx.sh

# COPY: Copy nginx configuration file into container
# conf/default.conf: Source - custom nginx site configuration
# /etc/nginx/conf.d/default.conf: Destination - nginx config directory
# nginx automatically loads all .conf files from conf.d directory
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# ENTRYPOINT: Define the main command that runs when container starts
# ["nginx", "-g", "daemon off;"]: JSON array format (exec form)
# nginx: Start nginx web server
# -g: Set global directives
# "daemon off;": Run nginx in foreground (not as background daemon)
# This is critical for Docker - container stays alive while nginx runs
# If nginx daemonizes, container would exit immediately
ENTRYPOINT ["nginx", "-g", "daemon off;"]
