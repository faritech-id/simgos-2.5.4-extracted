USE `layanan`;

ALTER TABLE `order_lab`
	ADD COLUMN `PERMINTAAN_DARAH` TINYINT(3) NOT NULL DEFAULT '0' AFTER `ADA_PENGANTAR_PA`,
	ADD INDEX `PERMINTAAN_DARAH` (`PERMINTAAN_DARAH`);
