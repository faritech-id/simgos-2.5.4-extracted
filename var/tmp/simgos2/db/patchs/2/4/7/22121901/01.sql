USE `kemkes-ihs`;
ALTER TABLE `observation`
	ADD COLUMN `issued` CHAR(150) NULL DEFAULT NULL AFTER `effectiveDateTime`,
	ADD COLUMN `performer` JSON NULL DEFAULT NULL AFTER `issued`,
	ADD COLUMN `specimen` JSON NULL DEFAULT NULL AFTER `performer`,
	ADD COLUMN `basedOn` JSON NULL DEFAULT NULL AFTER `specimen`,
	ADD COLUMN `valueString` VARCHAR(250) NULL DEFAULT NULL AFTER `basedOn`,
	CHANGE COLUMN `refId` `refId` CHAR(20) NOT NULL DEFAULT '0' AFTER `interpretation`,
	CHANGE COLUMN `jenis` `jenis` TINYINT(3) NOT NULL COMMENT '1:  Nadi, 2: Pernapasan, 3: Sistol, 4: Diastol, 5: Suhu 6: lab' AFTER `refId`,
	ADD INDEX `id` (`id`);
