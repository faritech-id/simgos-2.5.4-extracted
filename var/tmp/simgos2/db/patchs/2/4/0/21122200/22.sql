USE medicalrecord;

ALTER TABLE `jadwal_kontrol`
	ADD COLUMN `NOMOR_REFERENSI` CHAR(25) NULL AFTER `NOMOR`;