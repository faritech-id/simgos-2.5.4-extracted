-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.32 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk inventory
USE `inventory`;

-- membuang struktur untuk function inventory.getPeriodeAkhirSo
DROP FUNCTION IF EXISTS `getPeriodeAkhirSo`;
DELIMITER //
CREATE FUNCTION `getPeriodeAkhirSo`(
	`PRUANGAN` CHAR(10)
) RETURNS datetime
    DETERMINISTIC
BEGIN
	DECLARE VPERIODE DATETIME;
	
	IF EXISTS(
		SELECT 1
		  FROM information_schema.`COLUMNS` c
		 WHERE c.TABLE_SCHEMA = 'inventory'
		   AND c.TABLE_NAME = 'stok_opname'
		   AND c.COLUMN_NAME = 'TIME'
		LIMIT 1) THEN
		SELECT DATE_FORMAT(CONCAT(TANGGAL, ' ', `TIME`), '%Y-%m-%d %H:%i:%s') 
		  INTO VPERIODE 
		  FROM inventory.stok_opname 
		 WHERE RUANGAN = PRUANGAN 
		   AND STATUS = 'Final' 
		 ORDER BY TANGGAL DESC 
		 LIMIT 1;
	ELSE
		SELECT DATE_FORMAT(TANGGAL, '%Y-%m-%d %H:%i:%s') 
		  INTO VPERIODE 
		  FROM inventory.stok_opname 
		 WHERE RUANGAN = PRUANGAN 
		   AND STATUS = 'Final' 
		 ORDER BY TANGGAL DESC 
		 LIMIT 1;
	END IF;
	
	IF NOT VPERIODE IS NULL THEN
		RETURN VPERIODE;
	END IF;
	
	RETURN '2000-01-01 00:00:01';
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
