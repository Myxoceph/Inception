ARG RELEASE=bullseye

FROM debian:${RELEASE}

RUN apt-get update && apt-get install -y php php-mysqli php-fpm php-cli wget curl tar mariadb-client && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /var/www/wordpress
RUN mkdir -p /run/php

RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
 && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
 && cp -r /tmp/wordpress/* /var/www/wordpress/ \
 && rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /usr/local/bin/wp

COPY tools/wordpress.sh /wordpress.sh
RUN chmod +x /wordpress.sh

EXPOSE 9000
ENTRYPOINT ["/wordpress.sh"]
