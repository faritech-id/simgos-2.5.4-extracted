USE `master`;

-- Dumping structure for function master.getRuangPenunjang
DROP FUNCTION IF EXISTS `getRuangPenunjang`;
DELIMITER //
CREATE FUNCTION `getRuangPenunjang`(
	`PNOMOR` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(RUANGAN SEPARATOR ';'))  INTO HASIL
	FROM (SELECT CONCAT('- ',mr.DESKRIPSI) RUANGAN
			FROM master.ruangan mr,
				  pendaftaran.kunjungan k
				  LEFT JOIN pendaftaran.pendaftaran p ON k.NOPEN=p.NOMOR
			WHERE mr.ID=k.RUANGAN AND k.`STATUS`!=0 AND k.REF IS NOT NULL
			AND mr.JENIS_KUNJUNGAN IN (1,4,5,6,7,8,9,10) AND p.NOMOR=PNOMOR
			GROUP BY mr.ID) a
	ORDER BY RUANGAN;

	RETURN HASIL;
END//
DELIMITER ;
