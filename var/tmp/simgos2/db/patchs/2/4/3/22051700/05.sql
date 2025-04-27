USE `master`;

ALTER TABLE `smf_ruangan`
	CHANGE COLUMN `SMF` `SMF` TINYINT NOT NULL COMMENT 'Spesialis/Sub. Spesialis' AFTER `RUANGAN`;