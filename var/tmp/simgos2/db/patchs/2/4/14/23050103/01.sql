use `medicalrecord`;

ALTER TABLE `penilaian_nyeri`
	DROP INDEX `KUNJUNGAN`,
	ADD INDEX `KUNJUNGAN` (`KUNJUNGAN`),
	ADD INDEX `STATUS` (`STATUS`);

