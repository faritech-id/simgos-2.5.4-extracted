# BRIDGING SIMRS <-> WINACOM

## DB

Restore db vanslab yang ada di lokasi folder db.
Restore db sebaiknya jangan digabungkan dengan db simrsgosv2 untuk keamanan.
Jika menggunakan db simrsgosv2 maka buat user khusus dimana hak akses hanya SELECT, INSERT dan UPDATE

## Konfigurasi

Tambahkan Adapter pada file local.php

```php
'WinacomAdapter' => [
    'database' => 'lis_bridging',
    'driver' => 'PDO_Mysql',
    'hostname' => '',
    'username' => '',
    'password' => '',
],
```

Silahkan baca petunjuk README.md di folder /var/www/html/production/webapps/scripts/list_scheduler/lis
