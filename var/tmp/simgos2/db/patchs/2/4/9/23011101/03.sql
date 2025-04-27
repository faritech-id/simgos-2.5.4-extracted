-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk function master.getDeskripsiICD
DROP FUNCTION IF EXISTS `getDeskripsiICD`;
DELIMITER //
CREATE FUNCTION `getDeskripsiICD`(
	`PCODE` CHAR(6)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT mr.STR INTO HASIL
		FROM master.mrconso mr
		WHERE mr.SAB IN ('ICD10_1998','ICD10_2020','ICD9CM_2005','ICD9CM_2020') AND TTY IN ('PX', 'PT') AND mr.CODE=PCODE
	GROUP BY mr.CODE
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
