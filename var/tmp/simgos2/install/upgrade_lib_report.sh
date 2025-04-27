#!/bin/sh

cd ~

sudo sed -i '$ a Install dan Upgrade Library Report' /var/log/simgos2.log
echo  "Install / Upgrade Library Report"
if [ ! -f upgrade-lib-javabridge.sh ]; then
    sudo wget http://simgos2.simpel.web.id/repos/java/jasperreports/upgrade-lib-javabridge.sh

    # Berikan akses execute
    sudo sed -i -e 's/\r$//' upgrade-lib-javabridge.sh
    sudo chmod +x upgrade-lib-javabridge.sh

    # Eksekusi perintah upgrade-lib-javabridge.sh
    sudo ./upgrade-lib-javabridge.sh
fi
sudo sed -i 's/Install dan Upgrade Library Report/Install dan Upgrade Library Report ......... OK/g' /var/log/simgos2.log
