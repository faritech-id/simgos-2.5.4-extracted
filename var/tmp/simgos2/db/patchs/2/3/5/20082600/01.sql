USE aplikasi;

ALTER TABLE `modules`
	ADD COLUMN `CONFIG` JSON NULL DEFAULT NULL AFTER `CLASS`;