USE `master`;

ALTER TABLE `ruangan`
	CHANGE COLUMN `DESKRIPSI` `DESKRIPSI` VARCHAR(250) NOT NULL AFTER `REF_ID`;
