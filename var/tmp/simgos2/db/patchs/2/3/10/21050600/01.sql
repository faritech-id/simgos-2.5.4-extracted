USE pendaftaran;

ALTER TABLE `kunjungan`
	ADD COLUMN `DPJP` SMALLINT NULL DEFAULT NULL AFTER `FINAL_HASIL_TANGGAL`;