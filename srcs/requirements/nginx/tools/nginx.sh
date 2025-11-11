# Shebang: Specifies bash interpreter for this script
#!/bin/bash

# set: Modify shell behavior
# -e: Exit immediately if any command fails (non-zero exit status)
# This ensures script stops on first error rather than continuing
set -e

# mkdir: Make directory
# -p: Create parent directories as needed, no error if exists
# /etc/nginx/certs: Directory to store SSL certificates
mkdir -p /etc/nginx/certs

# if: Conditional statement
# [ ! -f /path ] || [ ! -f /path ]: Combined condition with OR
# -f: Test if file exists and is a regular file
# !: Negate the test (true if file does NOT exist)
# ||: Logical OR - true if either condition is true
# This checks if either certificate or key file is missing
if [ ! -f /etc/nginx/certs/server.crt ] || [ ! -f /etc/nginx/certs/server.key ]; then
	# openssl: OpenSSL command line tool
	# req: Certificate request and certificate generating utility
	# -x509: Output a self-signed certificate instead of certificate request
	# -nodes: Don't encrypt the private key (no DES - no password required)
	# -days 365: Certificate validity period (1 year)
	# -newkey rsa:2048: Generate new RSA private key with 2048 bits
	# -keyout: Specify output file for private key
	# /etc/nginx/certs/server.key: Path where private key is saved
	# -out: Specify output file for certificate
	# /etc/nginx/certs/server.crt: Path where certificate is saved
	# -subj: Set certificate subject information (avoids interactive prompts)
	# "/C=TR": Country = Turkey
	# "/ST=Turkey": State = Turkey
	# "/L=Kocaeli": Locality = Kocaeli
	# "/O=42": Organization = 42
	# "/OU=abakirca": Organizational Unit = abakirca (your username)
	# "/CN=abakirca.42.fr": Common Name = domain name (must match server_name)
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/certs/server.key \
		-out /etc/nginx/certs/server.crt \
		-subj "/C=TR/ST=Turkey/L=Kocaeli/O=42/OU=abakirca/CN=abakirca.42.fr"
# fi: End of if statement
fi
