USE `medicalrecord`;

ALTER TABLE `cppt`
	ADD COLUMN `SUB_DEVISI` SMALLINT NOT NULL DEFAULT 0 COMMENT 'referensi jenis = 26' AFTER `TANGGAL_RENCANA_PULANG`;