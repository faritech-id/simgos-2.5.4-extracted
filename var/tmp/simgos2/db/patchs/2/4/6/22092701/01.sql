USE `master`;

ALTER TABLE `jenis_referensi`
	CHANGE COLUMN `DESKRIPSI` `DESKRIPSI` VARCHAR(250) NOT NULL AFTER `ID`;
