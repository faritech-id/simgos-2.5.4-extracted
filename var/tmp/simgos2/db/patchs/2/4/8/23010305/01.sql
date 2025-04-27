USE pembatalan;

ALTER TABLE `pembatalan_final_hasil`
	ADD COLUMN `REF` CHAR(19) NOT NULL AFTER `KUNJUNGAN`;