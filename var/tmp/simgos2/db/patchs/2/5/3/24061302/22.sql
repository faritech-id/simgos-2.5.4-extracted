USE `master`;

-- Dumping structure for function master.getTindakan
DROP FUNCTION IF EXISTS `getTindakan`;
DELIMITER //
CREATE FUNCTION `getTindakan`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR ';'))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOPEN = PNOPEN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;