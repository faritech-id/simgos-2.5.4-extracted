USE `master`;

ALTER TABLE `dokter_smf`
	CHANGE COLUMN `SMF` `SMF` TINYINT NOT NULL COMMENT 'Spesialis/Sub. Spesialis' AFTER `DOKTER`;