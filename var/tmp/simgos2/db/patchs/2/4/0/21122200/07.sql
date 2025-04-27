USE bpjs;

ALTER TABLE `rujukan_khusus`
	ADD COLUMN `status` TINYINT NOT NULL DEFAULT '1' AFTER `tglrujukan_berakhir`;