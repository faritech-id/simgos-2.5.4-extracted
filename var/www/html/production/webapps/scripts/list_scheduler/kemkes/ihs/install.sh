#!/bin/sh

chmod +x run.sh

cat > /etc/cron.d/ihs <<-EOF
0/15 * * * * root /var/www/html/production/webapps/scripts/list_scheduler/kemkes/ihs/run.sh
EOF