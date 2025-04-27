USE bpjs;

ALTER TABLE `peserta`
	CHANGE COLUMN `nmJenisPeserta` `nmJenisPeserta` VARCHAR(50) NULL DEFAULT NULL AFTER `kdJenisPeserta`;