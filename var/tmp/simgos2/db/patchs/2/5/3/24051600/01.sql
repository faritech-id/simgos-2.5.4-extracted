USE aplikasi;

ALTER TABLE aplikasi.properti_config MODIFY COLUMN VALUE varchar(1000) DEFAULT '' NOT NULL;

UPDATE aplikasi.properti_config
   SET VALUE = JSON_SET(VALUE, '$.footer', 'Dokumen ini telah ditandatangani secara elektronik yang diterbitkan oleh Balai Sertifikasi Elektronik (BSrE), BSSN')
 WHERE ID = 87;