USE `layanan`;

ALTER TABLE `hasil_pa`
	ADD COLUMN `NOMOR_PA` VARCHAR(20) NULL DEFAULT NULL AFTER `JENIS_PEMERIKSAAN`,
	ADD COLUMN `PA_SEBELUMNYA` VARCHAR(50) NULL DEFAULT NULL AFTER `NOMOR_PA`,
	ADD COLUMN `JARINGAN` VARCHAR(50) NULL DEFAULT NULL AFTER `PA_SEBELUMNYA`,
	ADD COLUMN `PERMINTAAN_IHC` VARCHAR(100) NULL DEFAULT NULL AFTER `JARINGAN`,
	ADD COLUMN `ASISTEN` VARCHAR(100) NULL DEFAULT NULL AFTER `PERMINTAAN_IHC`;