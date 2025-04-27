USE bpjs;

ALTER TABLE `kunjungan`
	CHANGE COLUMN `klsRawat` `klsRawat` TINYINT NULL DEFAULT NULL COMMENT 'kelas rawat hak' AFTER `eksekutif`,
	ADD COLUMN `klsRawatNaik` TINYINT NULL DEFAULT NULL AFTER `klsRawat`,
	ADD COLUMN `pembiayaan` TINYINT NULL DEFAULT NULL AFTER `klsRawatNaik`,
	ADD COLUMN `penanggungJawab` VARCHAR(150) NULL DEFAULT NULL AFTER `pembiayaan`,
	ADD COLUMN `tujuanKunj` TINYINT NULL DEFAULT '0' AFTER `kecamatan`,
	ADD COLUMN `flagProcedure` CHAR(1) NULL DEFAULT '' AFTER `tujuanKunj`,
	ADD COLUMN `kdPenunjang` CHAR(2) NULL DEFAULT '' AFTER `flagProcedure`,
	ADD COLUMN `assesmentPel` CHAR(1) NULL DEFAULT '' AFTER `kdPenunjang`,
	ADD COLUMN `dpjpLayan` CHAR(7) NULL DEFAULT NULL AFTER `assesmentPel`;