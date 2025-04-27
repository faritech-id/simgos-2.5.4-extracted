USE medicalrecord;
ALTER TABLE `edukasi_pasien_keluarga`
	CHANGE COLUMN `OLEH` `OLEH` SMALLINT NULL DEFAULT '1' AFTER `STATUS`;
