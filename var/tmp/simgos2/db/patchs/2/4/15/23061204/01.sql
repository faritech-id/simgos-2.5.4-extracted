use `medicalrecord`;

ALTER TABLE `surat_kelahiran`
	ADD COLUMN `NOMOR` CHAR(6) NOT NULL AFTER `KUNJUNGAN`;
ALTER TABLE `surat_kelahiran`
	ADD INDEX `NOMOR` (`NOMOR`);
