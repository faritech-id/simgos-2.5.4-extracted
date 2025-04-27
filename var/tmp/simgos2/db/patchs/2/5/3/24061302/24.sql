USE `master`;

-- Dumping structure for function master.getTindakanKunjungan
DROP FUNCTION IF EXISTS `getTindakanKunjungan`;
DELIMITER //
CREATE FUNCTION `getTindakanKunjungan`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR '; '))  INTO HASIL
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
			 AND k.NOMOR = PKUNJUNGAN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;