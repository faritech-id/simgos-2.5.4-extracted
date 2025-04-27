USE pendaftaran;

ALTER TABLE `kartu_identitas_penanggung_jawab`
	CHANGE COLUMN `NOMOR` `NOMOR` VARCHAR(25) NOT NULL AFTER `PENANGGUNG_JAWAB_ID`;
