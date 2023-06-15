#!/bin/sh

set -e

chown www-data:www-data /var/www/html/classes

exec php-fpm
