#!/bin/sh

set -e

cleanup () {
    set +e
    while true
    do
        C=/var/www/html/classes
        flock $C/replay.tsv -c "\
          awk -v time=$(date +%s) '"'$3'" + 60 * 30 > time' < $C/replay.tsv > $C/replay.cln; \
          mv $C/replay.cln $C/replay.tsv; \
          chown www-data:www-data $C/replay.tsv"
        find $C -mmin +30 -name "*.class" ! -name "Notes.class" -delete
        find /var/www/html/notes -mmin +30 -delete
        sleep 60
    done
}

chown www-data:www-data /var/www/html/classes
chown www-data:www-data /var/www/html/notes

# don't move, will break docker caching
cp /var/www/html/Notes.class /var/www/html/classes/Notes.class

cleanup &

exec php-fpm
