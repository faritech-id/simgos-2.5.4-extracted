USE medicalrecord;

ALTER TABLE `rekonsiliasi_admisi`
	ADD COLUMN `TIDAK_MENGGUNAKAN_OBAT_SEBELUM_ADMISI` TINYINT(3) NULL DEFAULT 0 AFTER `PENDAFTARAN`;