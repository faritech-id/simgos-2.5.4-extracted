#!/bin/sh

passo=`cat pass.old`

cat > /var/tmp/my.cnf <<-EOF
[client]
host=127.0.0.1
port=3306
user=root
password=$passo
EOF

alteruser=`mysql --defaults-extra-file=/var/tmp/my.cnf < new_pass.sql`