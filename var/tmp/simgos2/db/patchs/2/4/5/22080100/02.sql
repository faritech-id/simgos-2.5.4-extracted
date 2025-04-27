USE pendaftaran;

ALTER TABLE `antrian_ruangan`
	CHANGE COLUMN `JENIS` `JENIS` TINYINT NOT NULL COMMENT '1=Melalui Pendaftaran; 2=Konsul/Order' AFTER `NOMOR`,
    CHANGE COLUMN `REF` `REF` CHAR(21) NOT NULL COMMENT 'Tujuan Pasien / Konsul / Order' AFTER `JENIS`;