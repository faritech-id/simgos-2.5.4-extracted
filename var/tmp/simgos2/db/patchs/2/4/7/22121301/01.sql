USE `layanan`;

ALTER TABLE `order_lab`
	ADD COLUMN `ADA_PENGANTAR_PA` TINYINT NOT NULL DEFAULT '0' COMMENT '0=Tidak; 1=Ya' AFTER `KETERANGAN`,
	ADD COLUMN `SPESIMEN_KLINIS_ASAL_SUMBER` TINYINT NULL DEFAULT NULL COMMENT 'REF#210' AFTER `ADA_PENGANTAR_PA`,
	ADD COLUMN `SPESIMEN_KLINIS_CARA_PENGAMBILAN` TINYINT NULL DEFAULT NULL COMMENT 'REF#211' AFTER `SPESIMEN_KLINIS_ASAL_SUMBER`,
	ADD COLUMN `SPESIMEN_KLINIS_WAKTU_PENGAMBILAN` DATETIME NULL DEFAULT NULL AFTER `SPESIMEN_KLINIS_CARA_PENGAMBILAN`,
	ADD COLUMN `SPESIMEN_KLINIS_KONDISI_PENGAMBILAN` VARCHAR(500) NULL DEFAULT NULL AFTER `SPESIMEN_KLINIS_WAKTU_PENGAMBILAN`,
	ADD COLUMN `SPESIMEN_KLINIS_JUMLAH` INT NOT NULL DEFAULT '0' COMMENT 'Jumlah potongan/slice jaringan yang diambil' AFTER `SPESIMEN_KLINIS_KONDISI_PENGAMBILAN`,
	ADD COLUMN `SPESIMEN_KLINIS_VOLUME` INT NOT NULL DEFAULT '0' COMMENT 'Jumlah kuantitas spesimen yang akan diperiksa' AFTER `SPESIMEN_KLINIS_JUMLAH`,
	ADD COLUMN `FIKSASI_WAKTU` DATETIME NULL AFTER `SPESIMEN_KLINIS_VOLUME`,
	ADD COLUMN `FIKSASI_CAIRAN` VARCHAR(250) NOT NULL DEFAULT '0' COMMENT 'Nama bahan cairan fiksasi yang digunakan untuk fiksasi pada jaringan' AFTER `FIKSASI_WAKTU`,
	ADD COLUMN `FIKSASI_VOLUME_CAIRAN` INT NOT NULL DEFAULT '0' COMMENT 'Jumlah kuantitas dari cairan fiksasi yang digunakan pada spesimen' AFTER `FIKSASI_CAIRAN`,
	ADD COLUMN `SPESIMEN_KLINIS_PETUGAS_PENGAMBIL` SMALLINT NOT NULL DEFAULT '0' COMMENT 'Pegawai' AFTER `FIKSASI_VOLUME_CAIRAN`,
	ADD COLUMN `SPESIMEN_KLINIS_PETUGAS_PENGANTAR` SMALLINT NOT NULL DEFAULT '0' COMMENT 'Pegawai' AFTER `SPESIMEN_KLINIS_PETUGAS_PENGAMBIL`,
	ADD INDEX `ADA_PENGANTAR_PA` (`ADA_PENGANTAR_PA`);
