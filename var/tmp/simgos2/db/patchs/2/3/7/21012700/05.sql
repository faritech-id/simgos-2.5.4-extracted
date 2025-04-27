USE kemkes;

ALTER TABLE `kamar_simrs_rs_online`
	ADD COLUMN `covid` TINYINT NOT NULL DEFAULT 0 AFTER `tempat_tidur`;