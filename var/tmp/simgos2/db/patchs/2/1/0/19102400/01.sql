USE pendaftaran;

ALTER TABLE `antrian_ruangan`
	ADD INDEX `JENIS` (`JENIS`),
	ADD INDEX `REF` (`REF`);