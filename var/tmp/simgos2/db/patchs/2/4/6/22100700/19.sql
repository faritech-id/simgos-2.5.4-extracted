USE `master`;
ALTER TABLE `ruangan`
	ADD COLUMN `TANGGAL` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() AFTER `DESKRIPSI`;