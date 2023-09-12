
# Laravel Docker Alpine

A light weight dockerized laravel app using alpine linux as image base.

This package include:
- Alpine linux
- Nginx
- PHP 8.2
- PHP FPM
- Supervisor
- Cron

Web Server is serve using nginx and pass php cgi to php fpm.
Laravel schedule & jobs is handled by Supervisor & Cron.

You edit all configuration file inside "docker" folder to meet your needs.


## Usage/Examples

```shell
  cd /your/project/directory
  docker build -t your-image .
```

