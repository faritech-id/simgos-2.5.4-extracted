USE medicalrecord;
ALTER TABLE `perencanaan_rawat_inap`
	ADD COLUMN `INDIKASI` TEXT NOT NULL AFTER `TANGGAL`;
