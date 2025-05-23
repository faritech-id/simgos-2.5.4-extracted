USE pembayaran;

ALTER TABLE `pembayaran_tagihan`
	CHANGE COLUMN `NOMOR` `NOMOR` CHAR(11) NOT NULL FIRST,
	ADD COLUMN `JENIS_LAYANAN_ID` TINYINT NOT NULL DEFAULT '1' COMMENT 'REF#172' AFTER `JENIS`,
	ADD COLUMN `PENYEDIA_ID` SMALLINT NULL COMMENT 'Untuk Non Tunai' AFTER `JENIS_LAYANAN_ID`,
	CHANGE COLUMN `TANGGAL` `TANGGAL` DATETIME NOT NULL AFTER `PENYEDIA_ID`,
	ADD COLUMN `REKENING_ID` SMALLINT NULL COMMENT 'Transfer ke Rek. RS' AFTER `TANGGAL`,
	ADD COLUMN `NO_ID` CHAR(25) NULL COMMENT 'No. Kartu/VA/QRIS dst' AFTER `REKENING_ID`,
	ADD COLUMN `NAMA` VARCHAR(135) NULL DEFAULT NULL AFTER `NO_ID`,
	CHANGE COLUMN `REF` `REF` CHAR(20) NOT NULL COMMENT 'Nomor Referensi / Sesuai dgn Jenis Layanan' COLLATE 'latin1_swedish_ci' AFTER `NAMA`,
	ADD COLUMN `JENIS_KARTU_ID` TINYINT NULL COMMENT 'Khusus EDC REF#17' AFTER `REF`,
	ADD COLUMN `BANK_ID` SMALLINT NULL COMMENT 'Khusus EDC/Transfer Ke Rek.RS REF#16' AFTER `JENIS_KARTU_ID`,
	CHANGE COLUMN `DESKRIPSI` `DESKRIPSI` VARCHAR(150) NOT NULL AFTER `BANK_ID`,
	ADD COLUMN `BRIDGE` TINYINT NOT NULL DEFAULT 0 COMMENT '1=Bridging/Integrasi' AFTER `TOTAL`,
	ADD COLUMN `TRANSAKSI_KASIR_NOMOR` INT NOT NULL AFTER `BRIDGE`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`NOMOR`),
	ADD INDEX `JENIS_LAYANAN_ID` (`JENIS_LAYANAN_ID`),
	ADD INDEX `PENYEDIA_ID` (`PENYEDIA_ID`),
	ADD INDEX `NO_ID` (`NO_ID`),
	ADD INDEX `NAMA` (`NAMA`),
	ADD INDEX `BANK_ID` (`BANK_ID`),
	ADD INDEX `TRANSAKSI_KASIR_NOMOR` (`TRANSAKSI_KASIR_NOMOR`);

UPDATE pembayaran.pembayaran_tagihan pt
   SET pt.TRANSAKSI_KASIR_NOMOR = CAST(pt.REF AS UNSIGNED)
 WHERE pt.JENIS IN (1, 8);