#!/usr/bin/env bash

chmod 777 /var/www/html/classes

/etc/init.d/nginx start
/etc/init.d/php8.1-fpm start

tail -f /var/log/nginx/error.log
