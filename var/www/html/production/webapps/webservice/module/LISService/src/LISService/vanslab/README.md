# BRIDGING SIMRS <-> VANSLAB

## DB

Restore db vanslab yang ada di lokasi folder db.
Restore db sebaiknya jangan digabungkan dengan db simrsgosv2 untuk keamanan.
Jika menggunakan db simrsgosv2 maka buat user khusus dimana hak akses hanya SELECT, INSERT dan UPDATE

## Konfigurasi

Tambahkan Adapter pada file local.php

```php
'VanslabAdapter' => [
    'database' => 'lis_his',
    'driver' => 'PDO_Mysql',
    'hostname' => '',
    'username' => '',
    'password' => '',
],
```

Silahkan baca petunjuk README.md di folder /var/www/html/production/webapps/scripts/list_scheduler/lis

Pada db lis_his

- Lakukan setting tindakan lab simrs ke table map_item_order
- Lakukan mapping pada table map_ruangan_lab
