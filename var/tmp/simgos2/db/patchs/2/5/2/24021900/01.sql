USE layanan;
ALTER TABLE `pasien_meninggal`
	ADD COLUMN `CATATAN_VERIFIKASI` TEXT NOT NULL AFTER `JENIS_OPERASI`;
