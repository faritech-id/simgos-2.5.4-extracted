USE `layanan`;

-- Dumping structure for function layanan.getStatusTelaahResep
DROP FUNCTION IF EXISTS `getStatusTelaahResep`;
DELIMITER //
CREATE FUNCTION `getStatusTelaahResep`(`PNOMOR` CHAR(30), `PREF` INT, `PJENIS` INT) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	DECLARE VSTATUS INT(11);
	
	SELECT COUNT(*) INTO VSTATUS FROM layanan.telaah_awal_resep t
	WHERE t.RESEP = PNOMOR AND t.REF_TELAAH = PREF AND t.JENIS = PJENIS;
	
	IF VSTATUS > 0 THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
END//
DELIMITER ;