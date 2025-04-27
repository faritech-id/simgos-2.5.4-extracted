#!/bin/sh

cd /var/www/html/production/webapps
find . -name "*.py.off" -exec sh -c 'x={}; mv "$x" $(echo $x | sed 's/\.py.off/\.py/g')' \;