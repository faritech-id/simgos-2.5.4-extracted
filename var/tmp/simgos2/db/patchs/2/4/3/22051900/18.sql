USE pembayaran;

ALTER TABLE `pembayaran_tagihan`
	CHANGE COLUMN `STATUS` `STATUS` TINYINT NOT NULL DEFAULT '1' COMMENT '0=Batal, 1 = Belum Bayar, 2 = Sudah Bayar' AFTER `OLEH`;