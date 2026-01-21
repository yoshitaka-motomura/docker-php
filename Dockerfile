ARG PHP_VERSION=8.5.1

FROM php:${PHP_VERSION}-fpm-alpine

LABEL "org.opencontainers.image.description"="PHP-FPM Custom Image with PostgreSQL and Memcached"

WORKDIR /var/www/html

# Install dependencies and PHP extensions
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
    mysql-client msmtp perl wget procps shadow libzip libjpeg-turbo libwebp freetype icu \
    openssl supervisor git vim unzip fcgi libgcc \
    postgresql-dev libmemcached-dev

RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j"$(nproc)" \
    gd \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    intl \
    opcache \
    exif \
    zip \
    bcmath \
    pcntl && \
    pecl install redis && \
    pecl install mongodb && \
    pecl install apcu && \
    pecl install memcached && \
    docker-php-ext-enable \
    mongodb \
    redis \
    apcu \
    memcached && \
    apk del build-essentials && rm -rf /usr/src/php*

# Set timezone
RUN apk --update --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

# PHP Config
COPY ./configure/php/php.ini-production /usr/local/etc/php/php.ini

# Supervisor
COPY ./configure/supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /etc/supervisor.d \
    && touch /var/log/supervisord.log \
    && touch /var/run/supervisord.pid

# Composer Install
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Datadog Trace
RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php && \
    php datadog-setup.php --php-bin=all --enable-appsec --enable-profiling

# Security hardening
RUN \
    chmod u-s /usr/bin/chsh && \
    chmod u-s /usr/bin/gpasswd && \
    chmod u-s /usr/bin/passwd && \
    chmod u-s /usr/bin/chage && \
    chmod u-s /usr/bin/chfn && \
    chmod g-s /sbin/unix_chkpwd && \
    chmod u-s /usr/bin/expiry

EXPOSE 9000

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
