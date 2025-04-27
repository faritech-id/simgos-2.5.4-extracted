USE aplikasi;

ALTER TABLE `pengguna_akses_ruangan`
	ADD INDEX `PENGGUNA_STATUS` (`PENGGUNA`, `STATUS`);
