#!/bin/sh

set -e

chown www-data:www-data /var/www/html/classes
chown www-data:www-data /var/www/html/notes

# don't move, will break docker caching
cp /var/www/html/Notes.class /var/www/html/notes/Notes.class

exec php-fpm
