# BRIDGING SIMRS <-> NOVANET

## Konfigurasi

Tambahkan Adapter pada file local.php

```php
'NovanetAdapter' => [
    'charset' => '',
    'database' => 'Bio-Connect',
    'driver' => 'pdo_sqlsrv',
    'hostname' => '',
    'username' => 'sa',
    'password' => '',
],
```

Install Microsoft ODBC 17

```bash
cd ~
curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo
sudo yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
sudo ACCEPT_EULA=Y yum install -y msodbcsql17
```

Install pdo sqlsvr

```bash
yum -y install php-sqlsrv

systemctl restart php-fpm
```

Silahkan baca petunjuk README.md di folder /var/www/html/production/webapps/scripts/list_scheduler/lis

Pada db lis simrs

- Untuk GDS setting lis_kode_test pada table prefix_parameter_lis
- Setting ruangan lab pada table lis_tanpa_order_config
