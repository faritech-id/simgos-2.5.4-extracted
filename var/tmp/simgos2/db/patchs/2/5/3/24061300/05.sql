USE medicalrecord;
ALTER TABLE `riwayat_alergi`
	ADD COLUMN `KODE_REFERENSI` JSON NULL DEFAULT NULL AFTER `DESKRIPSI`;
