USE bpjs;

ALTER TABLE `kunjungan`
	ADD COLUMN `statusPulang` TINYINT NULL DEFAULT NULL AFTER `tglPlg`,
	ADD COLUMN `noSuratMeninggal` CHAR(50) NULL DEFAULT NULL AFTER `statusPulang`,
	ADD COLUMN `tglMeninggal` DATETIME NULL DEFAULT NULL AFTER `noSuratMeninggal`,
	ADD COLUMN `noLPManual` CHAR(50) NULL DEFAULT NULL AFTER `tglMeninggal`;