USE `master`;

ALTER TABLE `template_anatomi`
	CHANGE COLUMN `KSM` `KSM` INT NULL DEFAULT NULL COMMENT 'Spesialis/Sub. Spesialis' AFTER `ID`;