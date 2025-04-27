USE kemkes;

ALTER TABLE `data_tempat_tidur`
	ADD COLUMN `terpakai_suspek` SMALLINT NOT NULL DEFAULT '0' AFTER `terpakai`,
	ADD COLUMN `terpakai_konfirmasi` SMALLINT NOT NULL DEFAULT '0' AFTER `terpakai_suspek`;