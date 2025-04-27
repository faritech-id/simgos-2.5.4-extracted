USE aplikasi;

REPLACE INTO aplikasi.properti_config (ID, NAMA, VALUE, DESKRIPSI) VALUES(87, 'INTEGRASI TANDA TANGAN ELEKTRONIK', '{
    "enabled": false,
    "driver": "TTE.V1.Driver.BSrE",
    "url": "http://{DOMAIN}/api",
    "username": "{USERNAME_ENCODE_BASE64}",
    "password": "{PASSWORD_ENCODE_BASE64}",
    "timeout": 10,
    "params": {
        "tampilan": "invisible"
    }
}', 'Integrasi dengan penyedia tanda tangan elektronik');