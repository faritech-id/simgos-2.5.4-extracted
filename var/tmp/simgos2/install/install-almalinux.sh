#!/bin/sh

if [ -f /var/lib/rpm/.rpm.lock ]; then
    sudo rm -rf /var/lib/rpm/.rpm.lock
fi
if [ -f /var/lib/dnf/rpmdb_lock.pid ]; then
    sudo mv /var/lib/dnf/rpmdb_lock.pid /var/lib/dnf/rpmdb_lock.pid.bcp
fi

cd /var/www/html/production/webapps
find . -name "*.py.off" -exec sh -c 'x={}; mv "$x" $(echo $x | sed 's/\.py.off/\.py/g')' \;

find . -type f -name "*.sh" | xargs chmod +x

cd ~

old_version=`cat /var/log/simgos-latest.txt`
if [ "$old_version" != "" ]; then
    rpm -ev --allmatches --justdb simgos-$old_version
fi

if [ -f /var/log/simrsgos-latest.txt ]; then
    sudo yes | mv /var/log/simrsgos-latest.txt /var/log/simgos-latest.txt
fi

# Jika sudah install php
installed_php=`sudo rpm -qa php`
if [ "$installed_php" != "" ]; then
    cd /var/tmp/simgos2/db
    chpass=`sudo cat change_pass.txt`
    if [ "$chpass" = "1" ]; then
        sudo sed -i -e 's/\r$//' new_pass.sh
        chmod +x new_pass.sh
        sudo ./new_pass.sh
    fi

    cd ~

    rpm=`sudo cat /var/log/simgos-latest.txt`
    if [ "$rpm" != "" ]; then
        echo "AlmaLinux 9: Mulai" > /var/log/simgos2.log

        cd /var/tmp/simgos2/install
        sudo sed -i -e 's/\r$//' upgrade_lib_report.sh
        chmod +x upgrade_lib_report.sh
        sudo ./upgrade_lib_report.sh

        sudo sed -i '$ a Install & Patch DB' /var/log/simgos2.log
        echo "Install & Patch DB"
        cd /var/tmp/simgos2/db/patchs
        sudo sed -i -e 's/\r$//' patch.sh
        chmod +x patch.sh
        sudo ./patch.sh ""
        sudo sed -i 's/Install & Patch DB/Install & Patch DB ......... OK/g' /var/log/simgos2.log

        if [ -f /var/tmp/simgos2/db/config.php ]; then
            rm -rf /var/tmp/simgos2/db/config.php
            rm -rf /var/tmp/simgos2/db/config.php.dist
        fi

        if [ -f /var/tmp/simgos.id ]; then
            simgos=`cat /var/tmp/simgos.id`
            if [ "$simgos" = "1" ]; then
                cd /var/www/html/production/webapps/scripts/migrations
                sudo sed -i -e 's/\r$//' mode_klinik.sh
                chmod +x mode_klinik.sh
                sudo ./mode_klinik.sh
            fi
        fi
        
        sudo sed -i '$ a Selesai' /var/log/simgos2.log
        exit 0
    fi
fi

# Jika install menggunakan iso simgos2 tetapi belum update sama sekali

echo "AlmaLinux 9: Mulai" > /var/log/simgos2.log

sudo sed -i '$ a Install tools' /var/log/simgos2.log
echo "Install tools"
sudo dnf -y install dnf-utils nano wget unzip tar
sudo sed -i 's/Install tools/Install tools ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install httpd' /var/log/simgos2.log
echo "Install httpd"
installed_httpd=`rpm -qa httpd`
if [ "$installed_httpd" = "" ]; then
    sudo dnf -y install httpd
fi 
sudo sed -i 's/Install httpd/Install httpd ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install php7+' /var/log/simgos2.log
echo "Install php7+"
installed_epel=`sudo rpm -qa epel-release`
if [ "$installed_epel" = "" ]; then
    sudo dnf -y install epel-release
fi

installed_remi=`sudo rpm -qa remi-release`
if [ "$installed_remi" = "" ]; then
    sudo dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    sudo dnf -y module reset php
    sudo dnf -y module enable php:remi-7.4
fi
installed_php=`sudo rpm -qa php`
if [ "$installed_php" = "" ]; then
    sudo dnf -y install php-common php php-cli php-pdo php-mysqlnd php-opcache php-fpm php-soap php-intl php-pear php-bcmath php-gd php-json php-pecl-mcrypt php-mbstring php-pecl-ssh2 php-pecl-grpc php-pecl-protobuf
fi
sudo sed -i 's/Install php7+/Install php7+ ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install MySQL' /var/log/simgos2.log
echo "Install MySQL"
installed_mysql_release=`rpm -qa mysql80-community-release`
if [ "$installed_mysql_release" = "" ]; then
    sudo dnf -y install https://repo.mysql.com//mysql80-community-release-el9.rpm
fi

installed_mysql=`rpm -qa mysql-community-server`
if [ "$installed_mysql" = "" ]; then
    sudo dnf -y install mysql-community-client mysql-community-server
fi
sudo sed -i 's/Install MySQL/Install MySQL ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install Open JDK 11' /var/log/simgos2.log
echo "Install Open JDK 11"
installed_jdk11=`rpm -qa java-11-openjdk`
if [ "$installed_jdk11" = "" ]; then
    sudo dnf -y install java-11-openjdk tzdata-java
fi
sudo sed -i 's/Install Open JDK 11/Install Open JDK 11 ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install Tomcat 9' /var/log/simgos2.log
echo "Install Tomcat 9"
tomcat_version=`sudo curl -s https://tomcat.apache.org/download-90.cgi | grep "[0-9]\.[0-9]\.[0-9]\+</a>" | sed -e 's|.*>\(.*\)<.*|\1|g'`
if [ ! -f apache-tomcat-$tomcat_version.tar.gz ]; then
    sudo wget -q https://downloads.apache.org/tomcat/tomcat-9/v$tomcat_version/bin/apache-tomcat-$tomcat_version.tar.gz
fi
installed_tomcat=`sudo ls -l /opt/tomcat/bin/ | grep version.sh`
if [ "$installed_tomcat" = "" ]; then
    sudo groupadd tomcat
    sudo useradd -M -g tomcat -d /opt/tomcat tomcat
    sudo mkdir /opt/tomcat
    yes | sudo tar xvf apache-tomcat-$tomcat_version.tar.gz -C /opt/tomcat --strip-components=1
fi
sudo sed -i 's/Install Tomcat 9/Install Tomcat 9 ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Download JavaBridge' /var/log/simgos2.log
echo "Download JavaBridge"
if [ ! -f JavaBridge.war ]; then
    sudo wget -q http://simgos2.simpel.web.id/repos/java/php-java-bridge_7.2.1_documentation.zip -O JavaBridge.zip

    if [ ! -f JavaBridge.zip ]; then
        sudo wget -q https://onboardcloud.dl.sourceforge.net/project/php-java-bridge/Binary%20package/php-java-bridge_7.2.1/php-java-bridge_7.2.1_documentation.zip -O JavaBridge.zip --no-check-certificate
    fi

    sudo unzip -q JavaBridge.zip
    sudo rm -rf JavaBridge.zip documentation/
    sudo cp JavaBridge.war /opt/tomcat/webapps
fi
sudo sed -i 's/Download JavaBridge/Download JavaBridge ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install FTP' /var/log/simgos2.log
echo "Install FTP"
installed_vsftpd=`rpm -qa vsftpd`
if [ "$installed_vsftpd" = "" ]; then
    sudo dnf -y install vsftpd
    sudo setsebool -P ftp_home_dir on
    sudo semanage boolean -m ftpd_full_access --on
fi
sudo sed -i 's/Install FTP/Install FTP ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Install Percona Xtrabackup' /var/log/simgos2.log
echo "Install Percona Xtrabackup"
installed_xtrabackup_release=`rpm -qa percona-release`
if [ "$installed_xtrabackup_release" = "" ]; then
    dnf -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    percona-release enable-only tools release
fi
installed_xtrabackup=`rpm -qa percona-xtrabackup-80`
if [ "$installed_xtrabackup" = "" ]; then
    sudo dnf -y install percona-xtrabackup-80
fi
sudo sed -i 's/Install Percona Xtrabackup/Install Percona Xtrabackup ......... OK/g' /var/log/simgos2.log

echo "Active to directory webapps"
cd /var/tmp/simgos2

sudo sed -i '$ a Copy Configuration Files' /var/log/simgos2.log
echo "Copy Configuration Files"
sudo yes | cp install/config/selinux /etc/sysconfig/
sudo sed -i -e 's/\r$//' /etc/sysconfig/selinux

sudo yes | cp install/config/sudoers /etc/
sudo sed -i -e 's/\r$//' /etc/sudoers

sudo yes | cp install/config/00-base.conf /etc/httpd/conf.modules.d/
sudo yes | cp install/config/httpd.conf /etc/httpd/conf/
sudo yes | cp install/config/php.conf /etc/httpd/conf.d/
sudo yes | cp install/config/alias.conf /etc/httpd/conf.d/
sudo yes | cp install/config/headers.conf /etc/httpd/conf.d/
sudo yes | cp install/config/www.conf /etc/php-fpm.d/
sudo yes | cp install/config/my.cnf /etc/
sudo yes | cp install/config/tomcat.service /etc/systemd/system/
sudo yes | cp install/config/tomcat-users.xml /opt/tomcat/conf/
sudo yes | cp install/config/catalina.properties /opt/tomcat/conf/
sudo yes | cp install/config/context.xml /opt/tomcat/webapps/manager/META-INF/
sudo yes | cp install/config/context.xml2 /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo yes | cp install/config/setenv.sh /opt/tomcat/bin/

sudo yes | cp install/config/vsftpd.conf /etc/vsftpd/
sudo yes | cp install/config/vsftpd.userlist /etc/
sudo setsebool -P ftp_home_dir on
sudo semanage boolean -m ftpd_full_access --on
sudo sed -i 's/Copy Configuration Files/Copy Configuration Files ......... OK/g' /var/log/simgos2.log

installed_jdk=`rpm -qa java-11-openjdk`
sudo sed -i -e "s/LOKASI_JDK/$installed_jdk/" /etc/systemd/system/tomcat.service

sudo sed -i '$ a Reload Daemon Service' /var/log/simgos2.log
echo "Reload Daemon Service"
sudo systemctl daemon-reload
sudo sed -i 's/Reload Daemon Service/Reload Daemon Service ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Configuration Tomcat' /var/log/simgos2.log
echo "Configuration Tomcat"
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf
sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/

sudo usermod -d /var/www/html/ simgos
sudo sed -i 's/Configuration Tomcat/Configuration Tomcat ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Configuration Directory WebService' /var/log/simgos2.log
echo "Configuration Directory WebService"
sudo chown simgos:simgos -Rf /var/www/html/
sudo chmod 755 -Rf /var/www/html/
sudo chmod 777 -Rf /var/www/html/production/webapps/webservice/logs
sudo chmod 777 -Rf /var/www/html/production/webapps/webservice/data/cache
sudo chmod 777 -Rf /var/www/html/production/webapps/webservice/serial
sudo chmod 777 -Rf /var/www/html/production/webapps/webservice/reports/output

if [ ! -f /var/www/html/production/webapps/webservice/config/autoload/local.php ]; then
    mv /var/www/html/production/webapps/webservice/config/autoload/local.php.dist /var/www/html/production/webapps/webservice/config/autoload/local.php
fi

sudo rm -rf /var/www/html/production/webapps/webservice/data/cache/*.php
sudo rm -rf /etc/httpd/conf.d/welcome.conf
find /etc/httpd/conf.d -name "*.conf" -exec sh -c 'x={}; sed -i -e "s/Indexes //g" "$x"' \;
sudo sed -i 's/Configuration Directory WebService/Configuration Directory WebService ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Enable and Start Service' /var/log/simgos2.log
echo "Enabled Service"
sudo systemctl enable httpd php-fpm mysqld tomcat vsftpd

echo "Start Service"
sudo systemctl start mysqld httpd php-fpm tomcat vsftpd

sudo setenforce 0
sudo sed -i 's/Enable and Start Service/Enable and Start Service ......... OK/g' /var/log/simgos2.log

sudo sed -i '$ a Change Default Password After Install' /var/log/simgos2.log
echo "Change Default Password After Install"
mysql_pass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | sed 's/.*root@localhost: //'`"
sudo mysql --connect-expired-password -uroot -p$mysql_pass < /var/tmp/simgos2/install/config/users.sql
sudo sed -i 's/Change Default Password After Install/Change Default Password After Install ......... OK/g' /var/log/simgos2.log

if [ ! -d /var/www/html/tools ]; then
    mkdir -p /var/www/html/tools
fi

cd /var/tmp/simgos2/install
sudo sed -i -e 's/\r$//' upgrade_lib_report.sh
chmod +x upgrade_lib_report.sh
sudo ./upgrade_lib_report.sh

if [ ! -d /var/lib/mysql/aplikasi ]; then
    sudo sed -i '$ a Install dan Patch DB' /var/log/simgos2.log
    echo "Install & Patch DB"
    cd /var/tmp/simgos2/db
    sudo cp config.php.dist config.php

    passn=`cat pass.new`
    sudo sed -i -e "s/PASSWORD/$passn/" config.php

    sudo php install_db.php
    sudo rm -rf /var/tmp/simgos2/db/config.php
    sudo rm -rf /var/tmp/simgos2/db/config.php.dist
fi

cd patchs
sudo bash patch.sh ""
sudo sed -i 's/Install dan Patch DB/Install dan Patch DB ......... OK/g' /var/log/simgos2.log

userexists=`sed -n "/^document-storage/p" /etc/passwd`
if [ "$userexists" = "" ]; then
   sudo adduser document-storage
   echo "document-storage" | sudo passwd document-storage --stdin
   mkdir -p /var/data/document-storage
   usermod -d /var/data/document-storage document-storage
   chown document-storage:document-storage /var/data/document-storage
fi

sudo sed -i '$ a Enable Firewall' /var/log/simgos2.log
echo "Enable Firewall"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload
sudo sed -i 's/Enable Firewall/Enable Firewall ......... OK/g' /var/log/simgos2.log
sudo sed -i '$ a Selesai' /var/log/simgos2.log

if [ -f /var/lib/dnf/rpmdb_lock.pid.bcp ]; then
    sudo mv /var/lib/dnf/rpmdb_lock.pid.bcp /var/lib/dnf/rpmdb_lock.pid
fi