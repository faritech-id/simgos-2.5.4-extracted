USE medicalrecord;
ALTER TABLE `penilaian_skala_morse`
	DROP INDEX `KUNJUNGAN`,
	ADD INDEX `KUNJUNGAN` (`KUNJUNGAN`),
	ADD INDEX `STATUS` (`STATUS`);
