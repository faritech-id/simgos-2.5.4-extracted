USE aplikasi;

ALTER TABLE `properti_config`
	CHANGE COLUMN `VALUE` `VALUE` VARCHAR(500) NOT NULL DEFAULT '' AFTER `NAMA`;

REPLACE INTO `properti_config` (`ID`, `NAMA`, `VALUE`, `DESKRIPSI`) VALUES (86, 'UBAH_PASSWORD_RUTIN', '{\r\n  "enabled": true,\r\n  "allowEsc": false,\r\n  "updateSetiap": 365\r\n}', 'Untuk menampilkan form ubah kata sandi agar melakukan perubahan kata sandi');