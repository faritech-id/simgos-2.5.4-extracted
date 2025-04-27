USE `kemkes`;

ALTER TABLE `rekap_pasien_masuk`
	ADD COLUMN `id` INT NOT NULL AUTO_INCREMENT FIRST,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`id`),
	ADD UNIQUE INDEX `tanggal` (`tanggal`);