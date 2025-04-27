USE `kemkes-ihs`;
ALTER TABLE `type_code_reference`
	ADD INDEX `code` (`code`);
