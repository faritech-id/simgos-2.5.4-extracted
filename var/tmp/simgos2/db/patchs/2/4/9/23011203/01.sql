ALTER TABLE pembayaran.`piutang_pasien`
	ADD COLUMN `ID` INT NOT NULL AUTO_INCREMENT FIRST,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`ID`),
	ADD UNIQUE INDEX `TAGIHAN` (`TAGIHAN`),
    ADD INDEX `STATUS` (`STATUS`);
