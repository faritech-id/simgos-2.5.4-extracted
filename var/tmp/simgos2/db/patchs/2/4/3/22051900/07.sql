USE pembayaran;

ALTER TABLE `pembayaran_tagihan`
	ADD COLUMN `NOMOR` CHAR(11) NOT NULL DEFAULT '' AFTER `JENIS`;

UPDATE pembayaran.pembayaran_tagihan
   SET NOMOR = generator.generateNoPembayaran(DATE(TANGGAL))
 WHERE STATUS >= 0;