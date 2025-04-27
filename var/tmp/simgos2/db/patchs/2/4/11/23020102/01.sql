USE aplikasi;

ALTER TABLE `modules`
	ADD COLUMN `IDX` TINYINT NOT NULL DEFAULT '0' COMMENT 'Digunakan untuk mengurutkan menu' AFTER `D`,
	ADD INDEX `IDX` (`IDX`);