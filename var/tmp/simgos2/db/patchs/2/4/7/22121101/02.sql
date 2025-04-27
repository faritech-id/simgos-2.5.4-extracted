-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk aplikasi
USE `aplikasi`;

-- membuang struktur untuk function aplikasi.isUsingGroupPengguna
DROP FUNCTION IF EXISTS `isUsingGroupPengguna`;
DELIMITER //
CREATE FUNCTION `isUsingGroupPengguna`(
	`PGROUP` SMALLINT,
	`PPENGGUNA` SMALLINT
) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE VCHECKED INT DEFAULT 0;
	
	SELECT SUM(gpam.`STATUS`) 
	  INTO VCHECKED
	  FROM aplikasi.group_pengguna_akses_module gpam 
	  		 LEFT JOIN aplikasi.pengguna_akses pa ON pa.GROUP_PENGGUNA_AKSES_MODULE = gpam.ID 
	 WHERE gpam.GROUP_PENGGUNA = PGROUP
	   AND gpam.`STATUS` = 1
	   AND pa.PENGGUNA = PPENGGUNA
	   AND pa.`STATUS` = 1;
	   
	RETURN IF(VCHECKED IS NULL, 0, IF(VCHECKED > 0, 1, 0));
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
