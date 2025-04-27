USE `master`;

-- Dumping structure for function master.getNomorKonsul
DROP FUNCTION IF EXISTS `getNomorKonsul`;
DELIMITER //
CREATE FUNCTION `getNomorKonsul`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN

	
	
	DECLARE HASIL TEXT;
	
	SET SESSION group_concat_max_len = 1000000;
	
	SELECT (GROUP_CONCAT(KONSUL SEPARATOR ' \r'))
	  INTO HASIL
	  FROM (
		SELECT CONCAT('- Nomor Konsul : ',jk.KONSUL_NOMOR)  KONSUL
		  FROM pendaftaran.jawaban_konsul jk
				 LEFT JOIN master.dokter_smf mds ON jk.DOKTER = mds.DOKTER
				 LEFT JOIN master.referensi smf ON mds.SMF = smf.ID AND smf.JENIS = 26,
				 pendaftaran.kunjungan k
		 WHERE jk.KONSUL_NOMOR = k.REF
			AND k.`STATUS` != 0 AND jk.`STATUS`!=0
			AND k.NOPEN = PNOPEN
		
			GROUP BY jk.NOMOR
	  ) a;

	RETURN HASIL;
END//
DELIMITER ;