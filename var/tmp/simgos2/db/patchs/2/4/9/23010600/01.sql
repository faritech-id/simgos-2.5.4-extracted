use `layanan`;
ALTER TABLE `order_lab`
	ADD COLUMN `NOMOR_SPESIMEN` CHAR(25) NOT NULL AFTER `ADA_PENGANTAR_PA`;
