USE `master`;
ALTER TABLE `pegawai`
	ADD COLUMN `TANGGAL` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP() AFTER `WILAYAH`;