ARG RELEASE=bookworm

FROM debian:${RELEASE}

RUN apt-get update && apt-get install -y \
   php php-fpm php-cli php-mysqli \
   wget curl tar mariadb-client \
   && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /usr/src/wordpress /var/www/wordpress /run/php \
   && wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
   && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/ \
   && rm -f /tmp/wordpress.tar.gz

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
   && chmod +x /usr/local/bin/wp

COPY tools/wordpress.sh /wordpress.sh

RUN chmod +x /wordpress.sh

ENTRYPOINT ["/wordpress.sh"]
