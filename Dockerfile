FROM php:8.2.13-fpm-alpine3.18

WORKDIR /var/www/html

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
    mysql-client msmtp perl wget procps shadow libzip libjpeg-turbo libwebp freetype icu \
    openssl supervisor git vim unzip fcgi

RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j"$(nproc)" gd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install intl && \
    docker-php-ext-install opcache && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    pecl install redis && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable redis && \
    apk del build-essentials && rm -rf /usr/src/php*

RUN apk --update --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

## PHP Config
COPY ./configure/php/php.ini-production /usr/local/etc/php/php.ini

## Supervisor
COPY ./configure/supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /etc/supervisor.d \
    && touch /var/log/supervisord.log && \
    touch /var/run/supervisord.pid


## Composer Install
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD SCRIPT_NAME=/ping \
    SCRIPT_FILENAME=/ping \
    REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect 127.0.0.1:9000  || exit 1

#########
## CIS-DI-0008
#########

RUN \
    chmod u-s /usr/bin/chsh && \
    chmod u-s /usr/bin/gpasswd && \
    chmod u-s /usr/bin/passwd && \
    chmod u-s /usr/bin/chage && \
    chmod u-s /usr/bin/chfn && \
    chmod g-s /sbin/unix_chkpwd && \
    chmod u-s /usr/bin/expiry

EXPOSE 9000

ENTRYPOINT ["/usr/bin/supervisord", "-n","-c", "/etc/supervisord.conf"]
