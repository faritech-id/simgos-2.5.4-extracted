USE `medicalrecord`;

ALTER TABLE `perencanaan_rawat_inap`
	ADD COLUMN `JENIS_RUANG_PERAWATAN` SMALLINT NOT NULL AFTER `NOMOR_REFERENSI`,
	ADD COLUMN `JENIS_PERAWATAN` SMALLINT NOT NULL AFTER `JENIS_RUANG_PERAWATAN`;
