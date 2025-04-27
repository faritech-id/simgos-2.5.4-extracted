USE kemkes;
ALTER TABLE `data_tempat_tidur`
	ADD COLUMN `antrian` SMALLINT NOT NULL DEFAULT '0' AFTER `prepare_plan`;
