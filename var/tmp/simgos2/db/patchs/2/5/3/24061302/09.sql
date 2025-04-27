USE `master`;

-- Dumping structure for function master.getKonsulAnastesi
DROP FUNCTION IF EXISTS `getKonsulAnastesi`;
DELIMITER //
CREATE FUNCTION `getKonsulAnastesi`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN

	
	
	DECLARE HASIL TEXT;
	
	SET SESSION group_concat_max_len = 1000000;
	
	SELECT TGLKONSUL
	  INTO HASIL
	  FROM (
		SELECT CONCAT(k.TANGGAL,'\r',rk.DESKRIPSI) TGLKONSUL
		  FROM pendaftaran.konsul k
		  		 LEFT JOIN master.ruangan rk ON k.TUJUAN = rk.ID
				 LEFT JOIN master.dokter_smf mds ON k.DOKTER_ASAL = mds.DOKTER
				 LEFT JOIN master.referensi smf ON mds.SMF = smf.ID AND smf.JENIS = 26,
				 pendaftaran.kunjungan pk
		 WHERE k.KUNJUNGAN = pk.NOMOR
			AND k.`STATUS` != 0 AND k.`STATUS`!=0
			AND k.TUJUAN IN ('101272004','101272006')
			AND pk.NOPEN = PNOPEN
		
			GROUP BY k.NOMOR
			LIMIT 1
	  ) a;

	RETURN HASIL;
END//
DELIMITER ;