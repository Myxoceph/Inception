ARG RELEASE=bullseye

FROM debian:${RELEASE}

RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

COPY tools/nginx.sh /nginx.sh

RUN chmod +x /nginx.sh && /nginx.sh

COPY conf/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
