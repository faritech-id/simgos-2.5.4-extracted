USE pendaftaran;

ALTER TABLE `penjamin`
	CHANGE COLUMN `NAIK_KELAS` `NAIK_KELAS` CHAR(2) NULL DEFAULT '' COMMENT 'sesuai dgn referensi penjamin' AFTER `CATATAN`;