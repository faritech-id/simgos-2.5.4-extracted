use `master`;
ALTER TABLE `keluarga_pasien`
	ADD COLUMN `TANGGAL_LAHIR` DATE NOT NULL AFTER `PEKERJAAN`;
