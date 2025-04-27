USE pembayaran;

ALTER TABLE `pembayaran_tagihan`
	ADD COLUMN `BATAS_WAKTU` DATETIME NULL COMMENT 'Batas Waktu Pembayaran' AFTER `TANGGAL_DIBUAT`;