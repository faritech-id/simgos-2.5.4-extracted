USE pendaftaran;

ALTER TABLE `antrian_ruangan`
	ADD COLUMN `POS` CHAR(3) NOT NULL DEFAULT '' AFTER `NOMOR`;
