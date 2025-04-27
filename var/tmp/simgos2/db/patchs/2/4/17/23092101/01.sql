USE inacbg;

ALTER TABLE `dokumen_pendukung`
	ADD COLUMN `document_id` CHAR(36) NULL DEFAULT NULL AFTER `kirim_bpjs`,
	ADD COLUMN `tanggal` DATETIME NULL DEFAULT NULL AFTER `document_id`,
	ADD COLUMN `oleh` SMALLINT NULL DEFAULT NULL AFTER `tanggal`,
	ADD INDEX `document_id` (`document_id`),
	ADD INDEX `status` (`status`);
