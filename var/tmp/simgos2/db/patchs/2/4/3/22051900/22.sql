USE cetakan;

ALTER TABLE `kwitansi_pembayaran`
	ADD COLUMN `ID` INT NOT NULL AUTO_INCREMENT FIRST,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`ID`),
	ADD UNIQUE INDEX `TAGIHAN_TANGGAL` (`TAGIHAN`, `TANGGAL`);
