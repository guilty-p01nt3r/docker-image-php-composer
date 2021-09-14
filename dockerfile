FROM php:5.6-fpm-alpine

# Environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.yarn/bin:$PATH
ENV PHP_VERSION=5

USER root

WORKDIR /tmp

# Installing Bash
RUN apk add --no-cache bash

# Installing git
RUN apk add --no-cache git

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Install Node and NPM
RUN apk add  --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main/ nodejs=10.24.1-r0
RUN apk add  --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main/ npm=10.24.1-r0

# Install yarn
RUN npm install --global yarn

# Install PHP Extension for Laravel

## BCMath PHP Extension
RUN apk add --update php-bcmath

## Ctype PHP Extension
RUN apk add --update php-ctype

## JSON PHP Extension
RUN apk add --update php-json

## Mbstring PHP Extension
RUN apk add --update php-mbstring

## OpenSSL PHP Extension
RUN apk add --update php-openssl

## PDO PHP Extension
RUN apk add --update php-pdo

## Tokenizer PHP Extension
RUN apk add --update php-tokenizer

## XML PHP Extension
RUN apk add --update php-xml

## Sodium PHP Extension
# RUN apk add --update php-sodium libsodium-dev
# RUN docker-php-ext-configure sodium
# RUN docker-php-ext-install sodium

## Zip PHP Extension
RUN apk add --update libzip-dev
RUN docker-php-ext-install zip

## GD PHP Extension
RUN apk add --update libpng-dev
RUN docker-php-ext-install gd

## Bcmath PHP Extension
RUN docker-php-ext-install bcmath

## IMAP PHP Extension
RUN apk add --update imap-dev krb5-dev openssl-dev
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

RUN \
    adduser --disabled-password --gecos "" $IMAGE_USER && \
    echo "PATH=$(yarn global bin):$PATH" >> /root/.profile && \
    echo "PATH=$(yarn global bin):$PATH" >> /root/.bashrc && \
    echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir -p /var/www/html && \
    chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME

## Xdebug
RUN pecl channel-update pecl.php.net
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.2.3 \
    && docker-php-ext-enable xdebug

## Install mysql plugin
RUN docker-php-ext-install pdo pdo_mysql 

# Set final environment 

RUN echo xdebug.mode=coverage > /usr/local/etc/php/conf.d/xdebug.ini 

USER $IMAGE_USER

WORKDIR /var/www/html