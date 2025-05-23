USE `master`;

-- Dumping structure for function master.getAturanPakai2
DROP FUNCTION IF EXISTS `getAturanPakai2`;
DELIMITER //
CREATE FUNCTION `getAturanPakai2`(`PFREKUENSI` INT, `DOSIS` CHAR(50), `PRUTE` INT) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VATURAN_PAKAI VARCHAR(250);
	DECLARE VFREKUENSI,VRUTE VARCHAR(100);
	
	SELECT f.FREKUENSI INTO VFREKUENSI FROM master.frekuensi_aturan_resep f WHERE f.ID = PFREKUENSI;
	IF VFREKUENSI IS NULL THEN
		SET VFREKUENSI = '';
	END IF;
	
	SELECT r.DESKRIPSI INTO VRUTE FROM master.referensi r WHERE r.JENIS = 217 AND r.ID = PRUTE;
	IF VRUTE IS NULL THEN
		SET VRUTE = '';
	END IF;
	
	RETURN CONCAT(VFREKUENSI,'  ',DOSIS,'  ',VRUTE);
END//
DELIMITER ;