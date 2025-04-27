use medicalrecord;

ALTER TABLE `jadwal_kontrol`
	ADD COLUMN `NOMOR` CHAR(6) NOT NULL DEFAULT '' COMMENT 'Nomor Surat Kontrol' AFTER `KUNJUNGAN`,
	ADD INDEX `NOMOR` (`NOMOR`);