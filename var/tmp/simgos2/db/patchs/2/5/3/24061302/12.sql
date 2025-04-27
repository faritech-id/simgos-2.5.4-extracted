USE `master`;

-- Dumping structure for function master.getNopenIRD
DROP FUNCTION IF EXISTS `getNopenIRD`;
DELIMITER //
CREATE FUNCTION `getNopenIRD`(
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
			  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
		  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		WHERE pr.NORM=PNORM AND pr.TANGGAL < PTANGGAL AND HOUR(TIMEDIFF(PTANGGAL, pr.TANGGAL)) <= 24 AND pr.`STATUS`!=0 AND pr.NOMOR=tpr.NOPEN
		  AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=2		  
		  AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.`STATUS`!=0
		ORDER BY pr.TANGGAL DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;