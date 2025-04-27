USE `master`;

-- Dumping structure for function master.getNopenIRNA
DROP FUNCTION IF EXISTS `getNopenIRNA`;
DELIMITER //
CREATE FUNCTION `getNopenIRNA`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(10);
   
  SELECT pr.NOMOR INTO HASIL  
    FROM pendaftaran.pendaftaran pr
      , pendaftaran.tujuan_pasien tpr
      , master.ruangan rpr
      , pendaftaran.kunjungan kpr
      
    WHERE pr.NORM=PNORM AND pr.TANGGAL > PTANGGAL AND HOUR(TIMEDIFF(pr.TANGGAL,PTANGGAL)) <= 24 AND pr.STATUS!=0 AND pr.NOMOR=tpr.NOPEN
      AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=3
      AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.STATUS!=0
    LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;