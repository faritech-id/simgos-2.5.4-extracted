#!/bin/sh

passn=`cat /var/tmp/simgos2/db/pass.new`
tgl=$(date +%Y%m%d%H%M%S)
target=/var/data/backups/mysql

sudo mkdir -p /var/data/backups/mysql

cat > /var/tmp/xtrabackup.cnf <<-EOF
[Xtrabackup]
user=root
password=$passn
target-dir=$target/X$tgl
EOF

lastbackup=""
if [ -f /var/tmp/lastbackup.txt ]; then
   lastbackup=`cat /var/tmp/lastbackup.txt`
fi

/usr/bin/xtrabackup --defaults-extra-file=/var/tmp/xtrabackup.cnf --backup

sudo rm -rf /var/tmp/xtrabackup.cnf

tar -czf $target/X$tgl.tar.gz $target/X$tgl

if [ $lastbackup != "" ]; then
   rm -rf $target/X$lastbackup
fi

cat > /var/tmp/lastbackup.txt <<-EOF
$tgl
EOF

systemctl restart mysqld