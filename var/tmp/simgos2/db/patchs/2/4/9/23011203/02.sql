ALTER TABLE pembayaran.`piutang_perusahaan`
	ADD COLUMN `ID` INT NOT NULL AUTO_INCREMENT FIRST,
	DROP PRIMARY KEY,
	ADD UNIQUE INDEX `TAGIHAN_PENJAMIN` (`TAGIHAN`, `PENJAMIN`),
	ADD PRIMARY KEY (`ID`),
	ADD INDEX `STATUS` (`STATUS`);
