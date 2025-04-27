#!/bin/sh

echo "Change mode simgos to rs"

cat > /var/tmp/simgos.id <<-EOF
0
EOF

sudo chmod 777 /var/www/html/production/webapps/application/SIMpel/classic.json
sudo chmod 777 /var/www/html/production/webapps/application/SIMpel/classic.jsonp

sudo sed -i -e 's/"type":1/"type":0/' /var/www/html/production/webapps/application/SIMpel/classic.json
sudo sed -i -e 's/"type":1/"type":0/' /var/www/html/production/webapps/application/SIMpel/classic.jsonp

sudo chmod 755 /var/www/html/production/webapps/application/SIMpel/classic.json
sudo chmod 755 /var/www/html/production/webapps/application/SIMpel/classic.jsonp