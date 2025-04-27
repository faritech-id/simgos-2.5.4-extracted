#!/bin/sh

chmod +x run.sh

cat > /etc/cron.d/clearcache <<-EOF
0 1 * * * root /var/www/html/production/webapps/scripts/list_scheduler/clearcache/run.sh
EOF