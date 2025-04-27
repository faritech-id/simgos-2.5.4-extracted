#!/bin/sh

chmod +x vanslab.sh

cat > /etc/cron.d/lis_vanslab <<-EOF
* * * * * root /var/www/html/production/webapps/scripts/list_scheduler/lis/vanslab.sh
EOF
