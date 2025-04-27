USE `kemkes-ihs`;

ALTER TABLE `loinc_terminologi`
	ADD INDEX `nama_pemeriksaan` (`nama_pemeriksaan`);
