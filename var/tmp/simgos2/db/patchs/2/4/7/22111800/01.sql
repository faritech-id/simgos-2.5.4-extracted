USE aplikasi;

ALTER TABLE `pengguna`
	CHANGE COLUMN `JENIS` `JENIS` SMALLINT(5) NULL DEFAULT '1' COMMENT '1=Internal; 2=Eksternal;' AFTER `NIK`,
	ADD COLUMN `LOCK_APP` TINYINT NULL DEFAULT '1' AFTER `JENIS`;
