USE pendaftaran;

ALTER TABLE `jawaban_konsul`
	ADD COLUMN `NOMOR` INT NOT NULL AUTO_INCREMENT FIRST,
	CHANGE COLUMN `NOMOR` `KONSUL_NOMOR` CHAR(21) NOT NULL AFTER `NOMOR`,
	DROP PRIMARY KEY,
	ADD UNIQUE INDEX `KONSUL_NOMOR` (`KONSUL_NOMOR`),
	ADD PRIMARY KEY (`NOMOR`);
