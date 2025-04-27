use `medicalrecord`;

ALTER TABLE `pemeriksaan_eeg`
	ADD COLUMN `DOKTER` SMALLINT NOT NULL AFTER `SARAN`;
