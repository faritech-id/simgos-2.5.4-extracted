#!/bin/sh

chmod +x novanet.sh

cat > /etc/cron.d/lis_novanet <<-EOF
* * * * * root /var/www/html/production/webapps/scripts/list_scheduler/lis/novanet.sh
EOF
