FROM php:7.4-fpm-alpine3.15

# Environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.yarn/bin:$PATH
ENV PHP_VERSION=7

USER root

WORKDIR /tmp

# Installing Bash
RUN apk add --no-cache bash

# Installing git
RUN apk add --no-cache git

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Install Node and NPM
RUN apk add --update nodejs npm

# Install yarn
RUN npm install --global yarn

# Install PHP Extension for Laravel

## BCMath PHP Extension
RUN apk add --update php7-bcmath

## Ctype PHP Extension
RUN apk add --update php7-ctype

## JSON PHP Extension
RUN apk add --update php7-json

## Mbstring PHP Extension
RUN apk add --update php7-mbstring

## OpenSSL PHP Extension
RUN apk add --update php7-openssl

## PDO PHP Extension
RUN apk add --update php7-pdo

## Tokenizer PHP Extension
RUN apk add --update php7-tokenizer

## XML PHP Extension
RUN apk add --update php7-xml

## Sodium PHP Extension
RUN apk add --update libsodium-dev

RUN \
    adduser --disabled-password --gecos "" $IMAGE_USER && \
    echo "PATH=$(yarn global bin):$PATH" >> /root/.profile && \
    echo "PATH=$(yarn global bin):$PATH" >> /root/.bashrc && \
    echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir -p /var/www/html && \
    chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME

## Xdebug
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

## Install mysql plugin
RUN docker-php-ext-install pdo pdo_mysql sodium


## Install GD
# zlib and libpng (necessary to install gd)
RUN apk add --update zlib-dev libpng-dev
RUN docker-php-ext-install gd

## Install zip
# libzip (necessary to install zip)
RUN apk add --update libzip-dev
RUN docker-php-ext-install zip

#RUN docker-php-ext-install mbstring

# Set final environment 

USER $IMAGE_USER

WORKDIR /var/www/html
