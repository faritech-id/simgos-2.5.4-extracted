USE pembayaran;

ALTER TABLE `pembayaran_tagihan`
	ADD COLUMN `BIAYA_ADMIN` DECIMAL(60,2) NOT NULL DEFAULT 0 AFTER `DESKRIPSI`;