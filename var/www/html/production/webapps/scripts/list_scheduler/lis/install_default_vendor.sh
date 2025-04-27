#!/bin/sh

chmod +x default_vendor.sh

cat > /etc/cron.d/lis_default_vendor <<-EOF
* * * * * root /var/www/html/production/webapps/scripts/list_scheduler/lis/default_vendor.sh
EOF
