#!/bin/sh

passn=`cat /var/tmp/simgos2/db/pass.new`

cat > /var/tmp/my.cnf <<-EOF
[client]
host=127.0.0.1
port=3306
user=root
password=$passn
EOF

echo 'Patch data master'

mysql --defaults-extra-file=/var/tmp/my.cnf < /var/tmp/simgos2/install/config/klinik.sql

rm -Rf /var/tmp/my.cnf

bash mode_klinik.sh

sed -i -e 's/\"hash\":\"[0-9a-f]*\"/"hash":"4f2e025c15fd0c321ebedc91adeef183ecaa71f9"/' /var/www/html/production/webapps/application/SIMpel/classic.json
sed -i -e 's/\"hash\":\"[0-9a-f]*\"/"hash":"4f2e025c15fd0c321ebedc91adeef183ecaa71f9"/' /var/www/html/production/webapps/application/SIMpel/classic.jsonp