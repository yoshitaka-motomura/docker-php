FROM ghcr.io/yoshitaka-motomura/php:8.2.19

RUN apk add --no-cache nginx

COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord", "-n","-c", "/etc/supervisord.conf"]
