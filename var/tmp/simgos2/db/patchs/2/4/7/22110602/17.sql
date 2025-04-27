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

-- Dumping structure for function kemkes-ihs.getBza
DROP FUNCTION IF EXISTS `getBza`;
DELIMITER //
CREATE FUNCTION `getBza`(
	`PKODE` CHAR(10)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VRETURN JSON;
	
	SELECT JSON_OBJECT(
		'system', c.system,
		'code', bza.id ,
		'display', bza.display 
	)
	INTO
	VRETURN
	FROM `kemkes-ihs`.bza bza
	, `kemkes-ihs`.code_reference c
	WHERE c.id = 20
	AND bza.id = PKODE;
	
	RETURN VRETURN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
