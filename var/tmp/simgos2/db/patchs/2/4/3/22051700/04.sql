USE `pendaftaran`;

ALTER TABLE `tujuan_pasien`
	CHANGE COLUMN `SMF` `SMF` TINYINT NOT NULL COMMENT 'Spesialis/Sub. Spesialis' AFTER `RESERVASI`;