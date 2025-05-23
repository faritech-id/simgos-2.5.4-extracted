USE `medicalrecord`;
ALTER TABLE `pemeriksaan_dada`
	ADD COLUMN `THORAKS_SIMETRIS` TINYINT(3) NOT NULL DEFAULT '0' AFTER `PENDAFTARAN`,
	ADD COLUMN `THORAKS_ASIMETRIS` TINYINT(3) NOT NULL DEFAULT '0' AFTER `THORAKS_SIMETRIS`,
	ADD COLUMN `THORAKS_DESKRIPSI` TEXT NULL DEFAULT NULL AFTER `THORAKS_ASIMETRIS`,
	ADD COLUMN `COR` TEXT NULL DEFAULT NULL AFTER `THORAKS_DESKRIPSI`,
	ADD COLUMN `REGULER` TINYINT(3) NOT NULL DEFAULT '0' AFTER `COR`,
	ADD COLUMN `IREGULER` TINYINT(3) NOT NULL DEFAULT '0' AFTER `REGULER`,
	ADD COLUMN `MURMUR` TEXT NULL DEFAULT NULL AFTER `IREGULER`,
	ADD COLUMN `LAIN_LAIN` TEXT NULL DEFAULT NULL AFTER `MURMUR`,
	ADD COLUMN `PULMO_SUARA_NAFAS` TEXT NULL DEFAULT NULL AFTER `LAIN_LAIN`,
	ADD COLUMN `RONCHI` TINYINT(3) NOT NULL DEFAULT '0' AFTER `PULMO_SUARA_NAFAS`,
	ADD COLUMN `RONCHI_DEKSRIPSI` TEXT NULL DEFAULT NULL AFTER `RONCHI`,
	ADD COLUMN `WHEEZING` TINYINT(3) NOT NULL DEFAULT '0' AFTER `RONCHI_DEKSRIPSI`,
	ADD COLUMN `WHEEZING_DESKRIPSI` TEXT NULL DEFAULT NULL AFTER `WHEEZING`;