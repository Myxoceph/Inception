ARG RELEASE=bullseye

FROM debian:${RELEASE}

RUN apt-get update && apt-get install -y php php-mysqli php-fpm php-cli wget curl tar mariadb-client && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /var/www/wordpress
RUN mkdir -p /run/php

COPY tools/wordpress.sh /wordpress.sh
RUN chmod +x /wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/wordpress.sh"]
