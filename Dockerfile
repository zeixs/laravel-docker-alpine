FROM alpine:latest

WORKDIR /var/www/html/

# Essentials
RUN apk add --no-cache tzdata
ENV TZ=Asia/Jakarta

RUN apk add --no-cache zip unzip curl nginx supervisor

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing PHP
RUN apk add --no-cache php82 \
    php82-common \
    php82-fpm \
    php82-pdo \
    php82-opcache \
    php82-zip \
    php82-gd \
    php82-phar \
    php82-iconv \
    php82-cli \
    php82-curl \
    php82-openssl \
    php82-mbstring \
    php82-tokenizer \
    php82-fileinfo \
    php82-json \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-simplexml \
    php82-dom \
    php82-pdo_mysql \
    php82-tokenizer \
    php82-pecl-redis

RUN ln -s /usr/bin/php82 /usr/bin/php

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

RUN apk add nodejs yarn

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY ./docker/supervisor/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php8.2-fpm.pid

COPY ./docker/php/php-fpm.conf /etc/php82/php-fpm.conf
COPY ./docker/php/php.ini-production /etc/php82/php.ini

# Configure nginx
COPY ./docker/nginx/nginx.conf /etc/nginx/
COPY ./docker/nginx/webserver.conf /etc/nginx/modules/

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Building process
COPY . .
RUN composer install --no-dev
RUN chown -R nobody:nobody /var/www/html/storage
RUN yarn && yarn add npx && yarn production && yarn tailwind-production

# Run a cron job
ADD ./docker/cron/crontab.txt /crontab.txt
RUN /usr/bin/crontab /crontab.txt

# add log for supervisor laravel worker
RUN touch /var/www/html/storage/logs/worker.log

RUN php artisan key:generate --ansi

EXPOSE 80
CMD ["/usr/bin/supervisord"]