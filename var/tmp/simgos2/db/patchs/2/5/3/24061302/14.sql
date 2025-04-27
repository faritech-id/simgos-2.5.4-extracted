USE `master`;

-- Dumping structure for function master.getPelaksanaOperasi
DROP FUNCTION IF EXISTS `getPelaksanaOperasi`;
DELIMITER //
CREATE FUNCTION `getPelaksanaOperasi`(
	`PIDOPERASI` INT,
	`PJENIS` TINYINT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	  SELECT REPLACE(GROUP_CONCAT(IFNULL(master.getNamaLengkapPegawai(pg.NIP),po.PELAKSANA) SEPARATOR ';'),';',' ; ')  
	  INTO HASIL
	  FROM medicalrecord.pelaksana_operasi po
		  LEFT JOIN master.pegawai pg ON po.PELAKSANA=pg.ID
	WHERE po.OPERASI_ID=PIDOPERASI AND po.JENIS=PJENIS AND po.`STATUS`!=0;

	RETURN HASIL;
END//
DELIMITER ;