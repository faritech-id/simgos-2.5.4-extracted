USE kemkes;

ALTER TABLE `data_tempat_tidur`
	CHANGE COLUMN `id_tt` `id_tt` SMALLINT NOT NULL DEFAULT 0 AFTER `id`,
	CHANGE COLUMN `jumlah_ruang` `jumlah_ruang` SMALLINT NOT NULL DEFAULT 0 AFTER `ruang`,
	CHANGE COLUMN `jumlah` `jumlah` SMALLINT NOT NULL DEFAULT 0 AFTER `jumlah_ruang`,
	CHANGE COLUMN `terpakai` `terpakai` SMALLINT NOT NULL DEFAULT 0 AFTER `jumlah`,
	CHANGE COLUMN `prepare` `prepare` SMALLINT NOT NULL DEFAULT 0 COMMENT 'Cadangan Persiapan Realisasi' AFTER `terpakai`,
	CHANGE COLUMN `prepare_plan` `prepare_plan` SMALLINT NOT NULL DEFAULT 0 COMMENT 'Cadangan Persiapan Rencana' AFTER `prepare`;