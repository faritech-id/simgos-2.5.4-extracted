USE bpjs;

ALTER TABLE `kunjungan`
	ADD COLUMN `propinsi` CHAR(2) NULL AFTER `lokasiLaka`,
	ADD COLUMN `kabupaten` CHAR(4) NULL AFTER `propinsi`,
	ADD COLUMN `kecamatan` CHAR(4) NULL AFTER `kabupaten`;