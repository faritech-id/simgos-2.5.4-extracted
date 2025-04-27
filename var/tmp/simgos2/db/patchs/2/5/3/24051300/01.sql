USE `kemkes-ihs`;

ALTER TABLE `loinc_terminologi`
	ADD COLUMN `body_site_code` CHAR(25) NOT NULL DEFAULT '' AFTER `code_system`,
	ADD COLUMN `body_site_display` VARCHAR(300) NOT NULL DEFAULT '' AFTER `body_site_code`,
	ADD COLUMN `body_site_code_sistem` VARCHAR(300) NOT NULL DEFAULT '' AFTER `body_site_display`;
