USE bpjs;

ALTER TABLE `rujukan_khusus`
	ADD COLUMN `idRujukan` CHAR(15) NULL AFTER `noRujukan`;