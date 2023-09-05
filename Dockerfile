# FROM node:18.16.0-alpine3.17 as node_stage

# #install Yarn
# RUN apk add yarn

# RUN mkdir -p /opt/app
# WORKDIR /opt/app
# COPY ./ .
# RUN yarn

FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

RUN apk update
RUN apk add zlib-dev libpng-dev libsodium-dev libzip-dev zip

# install Yarn
RUN apk add yarn

# Configure PHP Extension Before Installation
RUN docker-php-ext-configure zip

# Install Php extension
RUN docker-php-ext-install pdo pdo_mysql gd sodium zip exif
