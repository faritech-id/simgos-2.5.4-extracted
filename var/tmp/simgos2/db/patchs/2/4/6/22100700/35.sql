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
-- Dumping structure for function kemkes-ihs.getEncounter
DELIMITER //
CREATE FUNCTION `getEncounter`(
	`PNOPEN` CHAR(50)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VRETURN JSON;
	
	SELECT
		JSON_OBJECT(
			'reference', CONCAT('Encounter/', en.id),
			'display', CONCAT('kunjungan ', JSON_UNQUOTE(JSON_EXTRACT(pat.`name`, '$[0].text')), ' pada tanggal ', pen.TANGGAL)
		)
	INTO 
		VRETURN
	FROM `kemkes-ihs`.encounter en
	LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = en.refId
	LEFT JOIN `kemkes-ihs`.patient pat ON pat.refId = pen.NORM
	WHERE en.refId = PNOPEN AND en.id IS NOT NULL AND pat.id IS NOT NULL;
	
	RETURN VRETURN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
