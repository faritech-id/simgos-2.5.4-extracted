USE medicalrecord;
ALTER TABLE `tanda_vital`
	ADD COLUMN `SATURASI_O2` DECIMAL(10,2) NULL DEFAULT NULL AFTER `SUHU`;
