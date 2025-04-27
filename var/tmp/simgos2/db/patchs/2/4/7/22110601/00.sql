USE `kemkes-ihs`;

ALTER TABLE `type_code_reference`
	ADD COLUMN `system` VARCHAR(150) NULL AFTER `display`;
