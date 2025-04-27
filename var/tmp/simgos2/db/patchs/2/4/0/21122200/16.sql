USE `penjamin_rs`;

ALTER TABLE `drivers`
	CHANGE COLUMN `CLASS` `CLASS` VARCHAR(100) NOT NULL DEFAULT 'pendaftaran.penjamin.umum.Form' COLLATE 'latin1_swedish_ci' AFTER `JENIS_PENJAMIN_ID`;