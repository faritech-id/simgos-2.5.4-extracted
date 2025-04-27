USE kemkes;

ALTER TABLE `data_tempat_tidur`
	ADD COLUMN `prepare` TINYINT NOT NULL DEFAULT '0' COMMENT 'Cadangan Persiapan Realisasi' AFTER `terpakai`,
	ADD COLUMN `prepare_plan` TINYINT NOT NULL DEFAULT '0' COMMENT 'Cadangan Persiapan Rencana' AFTER `prepare`,
	ADD COLUMN `covid` TINYINT NOT NULL DEFAULT '0' AFTER `prepare_plan`;

ALTER TABLE `tempat_tidur`
	ADD COLUMN `status` TINYINT NOT NULL DEFAULT '1' AFTER `nama_tt`;

ALTER TABLE `data_tempat_tidur`
	ADD COLUMN `ruang` VARCHAR(1000) NOT NULL DEFAULT '' AFTER `id_tt`;


ALTER TABLE `data_tempat_tidur`
	ADD COLUMN `id` SMALLINT NOT NULL AUTO_INCREMENT FIRST,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`id`),
	ADD UNIQUE INDEX `id_tt_ruang` (`id_tt`, `ruang`);