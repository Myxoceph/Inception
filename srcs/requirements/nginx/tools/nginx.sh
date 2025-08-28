#!/bin/bash

set -e

mkdir -p /etc/nginx/certs

if [ ! -f /etc/nginx/certs/server.crt ] || [ ! -f /etc/nginx/certs/server.key ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/certs/server.key \
		-out /etc/nginx/certs/server.crt \
		-subj "/C=TR/ST=Turkey/L=Kocaeli/O=42/OU=abakirca/CN=abakirca.42.fr"
fi
