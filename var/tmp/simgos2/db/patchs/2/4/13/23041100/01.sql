-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk function pendaftaran.getLamaDirawatAturan2
DROP FUNCTION IF EXISTS `getLamaDirawatAturan2`;
DELIMITER //
CREATE FUNCTION `getLamaDirawatAturan2`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VJML SMALLINT DEFAULT 0;
	
	IF PREF IS NULL THEN
		SET VJML = DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK);
		SET VJML = IF(VJML = 0, 1, VJML);
	ELSE
		RETURN DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK);
	END IF;
	
	RETURN VJML;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
