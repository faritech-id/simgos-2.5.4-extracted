-- --------------------------------------------------------
-- Host:                         192.168.137.8
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
-- Dumping structure for function kemkes-ihs.getParameterHasilLoincDeskription
DROP FUNCTION IF EXISTS `getParameterHasilLoincDeskription`;
DELIMITER //
CREATE FUNCTION `getParameterHasilLoincDeskription`(
	`PPARAMETER` INT
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VRETURN JSON;
	
	SELECT 
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				JSON_OBJECT(
					'system', lt.code_system
					, 'code', lt.code
					, 'display', lt.display
				)
			)
		)
		INTO 
		VRETURN
	FROM `kemkes-ihs`.parameter_hasil_to_loinc phtl
	LEFT JOIN `kemkes-ihs`.loinc_terminologi lt ON lt.id = phtl.LOINC_TERMINOLOGI
	WHERE phtl.PARAMETER_HASIL = PPARAMETER AND phtl.`STATUS` = 1 AND lt.id IS NOT NULL;
	
	RETURN VRETURN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
