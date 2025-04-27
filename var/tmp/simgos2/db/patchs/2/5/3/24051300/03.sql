USE `kemkes-ihs`;

ALTER TABLE `observation`
	ADD COLUMN `derivedFrom` JSON NULL DEFAULT NULL AFTER `bodySite`;
