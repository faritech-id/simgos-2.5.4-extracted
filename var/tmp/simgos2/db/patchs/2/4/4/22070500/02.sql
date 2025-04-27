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


-- Membuang struktur basisdata untuk generator
CREATE DATABASE IF NOT EXISTS `generator`;
USE `generator`;

-- membuang struktur untuk function generator.generateNoSuratSakit
DROP FUNCTION IF EXISTS `generateNoSuratSakit`;
DELIMITER //
CREATE FUNCTION `generateNoSuratSakit`(
	`PTAHUN` CHAR(4)
) RETURNS varchar(6) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VNOMOR MEDIUMINT DEFAULT 0;
	
	INSERT INTO generator.no_surat_sakit(TAHUN, URUT)
	SELECT IFNULL(a.TAHUN, PTAHUN), IFNULL(MAX(a.URUT), 0) + 1
	  FROM generator.no_surat_sakit a
	 WHERE TAHUN = PTAHUN;
	 
	SELECT a.URUT
	  INTO VNOMOR
	  FROM generator.no_surat_sakit a
	 WHERE a.ID = LAST_INSERT_ID();
	
	RETURN LPAD(VNOMOR, 6, '0');
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
