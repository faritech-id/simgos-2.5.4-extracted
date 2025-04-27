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
-- Dumping structure for function kemkes-ihs.getPractitioner
DROP FUNCTION IF EXISTS `getPractitioner`;
DELIMITER //
CREATE FUNCTION `getPractitioner`(
	`PNIP` VARCHAR(50)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VRETURN JSON;
	
	SELECT 
		IF(pr.id IS NOT NULL, JSON_OBJECT(
			'reference', CONCAT('Practitioner/', pr.id),
			'display',  JSON_UNQUOTE(JSON_EXTRACT(pr.`name`, '$[0].text'))
		), NULL) INTO VRETURN
	FROM `kemkes-ihs`.practitioner pr
	LEFT JOIN pegawai.kartu_identitas ki ON ki.NOMOR = pr.refId AND ki.JENIS = 1
	WHERE ki.NIP = PNIP;
	
	RETURN VRETURN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
