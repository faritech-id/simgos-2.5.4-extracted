USE `master`;

-- Dumping structure for function master.getRuangKonsul
DROP FUNCTION IF EXISTS `getRuangKonsul`;
DELIMITER //
CREATE FUNCTION `getRuangKonsul`(
	`PNORM` CHAR(10)
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
			AND mr.JENIS_KUNJUNGAN NOT IN (4,5,11) AND p.NORM=PNORM
			GROUP BY mr.ID) a
	ORDER BY RUANGAN;

	RETURN HASIL;
END//
DELIMITER ;