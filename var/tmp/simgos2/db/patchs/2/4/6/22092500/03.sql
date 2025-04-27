USE pendaftaran;

ALTER TABLE `kartu_identitas_pengantar_pasien`
	CHANGE COLUMN `NOMOR` `NOMOR` VARCHAR(25) NOT NULL AFTER `PENGANTAR_ID`;
