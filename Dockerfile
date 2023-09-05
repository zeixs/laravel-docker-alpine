FROM ubuntu:latest

ENV TZ="Asia/Jakarta"

RUN apt update
RUN apt install software-properties-common nginx -y
RUN add-apt-repository ppa:ondrej/php -y

RUN apt install -y libbz2-dev zlib1g-dev libpng-dev libsodium-dev libzip-dev php8.1 php8.1-cli php8.1-fpm php8.1-exif php8.1-gd php8.1-mysql php8.1-xml
RUN update-rc.d php8.1-fpm defaults && update-rc.d php8.1-fpm enable 

COPY . /var/www/html
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/default
WORKDIR /var/www/html

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "copy('https://composer.github.io/installer.sig', 'signature');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === trim(file_get_contents('signature'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN composer update \
    && php artisan vendor:publish --all \
    && yarn

RUN chmod -R 777 /var/www/html && apt clean

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]