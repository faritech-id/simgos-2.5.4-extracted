USE `kemkes-ihs`;
ALTER TABLE `loinc_terminologi`
	CHANGE COLUMN `Kategori_pemeriksaan` `kategori_pemeriksaan` VARCHAR(150) NOT NULL COLLATE 'latin1_swedish_ci' AFTER `id`,
	DROP INDEX `Kategori_pemeriksaan`,
	ADD INDEX `Kategori_pemeriksaan` (`kategori_pemeriksaan`) USING BTREE;
