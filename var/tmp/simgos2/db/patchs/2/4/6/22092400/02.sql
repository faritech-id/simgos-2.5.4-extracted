USE medicalrecord;

ALTER TABLE `riwayat_alergi`
	ADD COLUMN `JENIS` VARCHAR(10) NULL COMMENT 'REF#180' AFTER `KUNJUNGAN`;
