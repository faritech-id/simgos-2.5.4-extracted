-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE `kemkes-ihs`;

-- Dumping structure for function kemkes-ihs.getIdentifierUrutanLayananResep
DROP FUNCTION IF EXISTS `getIdentifierUrutanLayananResep`;
DELIMITER //
CREATE FUNCTION `getIdentifierUrutanLayananResep`(
	`PNOMOR` CHAR(21)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VRETURN JSON;
	DECLARE VURUT INT(10);
	
	SELECT
		COUNT(*)
		INTO 
		VURUT
	FROM
		`kemkes-ihs`.medication_dispanse m
	WHERE m.refId = PNOMOR;
	
	SELECT 
		JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', CONCAT(PNOMOR, '-', VURUT + 1)
		)
		INTO
		VRETURN
	FROM `kemkes-ihs`.organization org
	, `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	AND org.id IS NOT NULL
	AND c.id = 32;
	
	RETURN VRETURN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
