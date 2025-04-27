#!/bin/sh

chmod +x run.sh

cat > /etc/cron.d/sitb <<-EOF
0 1 * * * root /var/www/html/production/webapps/scripts/list_scheduler/kemkes/sitb/run.sh
EOF