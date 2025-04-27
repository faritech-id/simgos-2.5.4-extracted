USE `master`;

-- Dumping structure for function master.getDiagnosaPasien
DROP FUNCTION IF EXISTS `getDiagnosaPasien`;
DELIMITER //
CREATE FUNCTION `getDiagnosaPasien`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode),',',';') INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'-[',REPLACE(mr.STR,',',' '),'(',md.DIAGNOSA,')]') mrcode, md.ID, md.UTAMA 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE  AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE
	ORDER BY md.UTAMA , md.ID ) a
	ORDER BY UTAMA , ID ;

	RETURN HASIL;
END//
DELIMITER ;