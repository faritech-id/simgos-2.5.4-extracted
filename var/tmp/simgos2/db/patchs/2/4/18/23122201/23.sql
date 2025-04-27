-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for master
USE `master`;

-- Dumping structure for function master.getKodeDiagnosaPasien
DROP FUNCTION IF EXISTS `getKodeDiagnosaPasien`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosaPasien`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode),',',';') INTO HASIL
	FROM (SELECT (mr.CODE) mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE  AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE
	ORDER BY  md.ID) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
