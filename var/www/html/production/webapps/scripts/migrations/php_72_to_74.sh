yum install epel-release -y
yum install https://rpms.remirepo.net/enterprise/remi-release-7.9.rpm -y

yum install yum-utils -y

yum remove php* -y
yum remove php-* -y

yum-config-manager --enable remi-php74

yum install php php-bcmath php-cli php-common php-fedora-autoloader php-fpm php-gd php-intl php-json php-ldap php-mbstring php-mysqlnd php-opcache php-pdo php-pear php-pecl-mcrypt php-pecl-zip php-process php-soap php-xml php-pecl-ssh2 php-pecl-grpc php-pecl-protobuf -y

phpconf="/etc/httpd/conf.d/php.conf"
phpconfbcp="/etc/httpd/conf.d/php.conf.rpmsave"
if [[ -f $phpconfbcp ]]; then
    mv $phpconf /etc/httpd/conf.d/php.conf.bcp
    mv $phpconfbcp /etc/httpd/conf.d/php.conf
fi

systemctl restart php-fpm
systemctl restart httpd
systemctl enable php-fpm
