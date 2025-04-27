USE `master`;

-- Dumping structure for function master.getTglTindakanAwal
DROP FUNCTION IF EXISTS `getTglTindakanAwal`;
DELIMITER //
CREATE FUNCTION `getTglTindakanAwal`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	   SELECT tm.TANGGAL INTO VTANGGAL
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
		ORDER BY tm.TANGGAL ASC
		LIMIT 1;

	RETURN VTANGGAL;
END//
DELIMITER ;