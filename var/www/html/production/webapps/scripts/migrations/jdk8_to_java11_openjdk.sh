sudo yum -y install java-11-openjdk

openjdk=`rpm -qa java-11-openjdk`

sudo alternatives --set java /usr/lib/jvm/$openjdk/bin/java
sudo mv /etc/systemd/system/tomcat.service /etc/systemd/system/tomcat.service.bcp

sudo yes | cp /var/tmp/simgos2/install/config/tomcat.service /etc/systemd/system/

sudo sed -i -e "s/LOKASI_JDK/$openjdk/" /etc/systemd/system/tomcat.service

sudo systemctl stop tomcat
sudo rm -rf /opt/tomcat/log/*.*
sudo systemctl daemon-reload
sudo systemctl start tomcat
