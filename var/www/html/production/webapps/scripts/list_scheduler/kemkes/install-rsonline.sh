#!/bin/sh

chmod +x rsonline.sh

cat > /etc/cron.d/rsonline <<-EOF
0/5 * * * * root /var/www/html/production/webapps/scripts/list_scheduler/kemkes/rsonline.sh
EOF