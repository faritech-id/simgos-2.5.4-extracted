#!/bin/sh

installed_xtrabackup=`rpm -qa percona-release`
if [ "$installed_xtrabackup" = "" ]; then
    yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    percona-release enable-only tools release
fi

installed_xtrabackup=`rpm -qa percona-xtrabackup-80`
if [ "$installed_xtrabackup" = "" ]; then
    mysql_version=`rpm -qa mysql-community-server | sed 's/\mysql-community-server-//g' | sed 's/\.x86_64//g'`
    sudo yum -y install percona-xtrabackup-80-$mysql_version
fi

cat > /etc/cron.d/xtrabackup <<-EOF
00 01 * * * root /var/www/html/production/webapps/scripts/tools/xtrabackup.sh
EOF
