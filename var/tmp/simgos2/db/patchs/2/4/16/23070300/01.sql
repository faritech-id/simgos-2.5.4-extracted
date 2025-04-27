USE `medicalrecord`;

ALTER TABLE `riwayat_pemberian_obat`
	ADD COLUMN `FREKUENSI` INT NOT NULL COMMENT 'table frekuensi_aturan_resep' AFTER `DOSIS`,
	ADD COLUMN `RUTE` INT NOT NULL COMMENT 'table referensi JENIS = 217' AFTER `FREKUENSI`,
	ADD INDEX `FREKUENSI` (`FREKUENSI`),
	ADD INDEX `RUTE` (`RUTE`);