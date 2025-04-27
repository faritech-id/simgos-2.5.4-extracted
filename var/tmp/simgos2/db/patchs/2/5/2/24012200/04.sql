-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for inventory
USE `inventory`;

-- Dumping structure for function inventory.getHrgDasarBarang
DROP FUNCTION IF EXISTS `getHrgDasarBarang`;
DELIMITER //
CREATE FUNCTION `getHrgDasarBarang`(`PBARANG` INT, `PTANGGAL` DATE) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VHARGA DECIMAL(60,2);
	
	SELECT HARGA_JUAL INTO VHARGA 
	  FROM `inventory`.harga_barang
	 WHERE BARANG = PBARANG AND MASA_BERLAKU <= PTANGGAL
	  
	 ORDER BY MASA_BERLAKU DESC, ID DESC LIMIT 1;
	 
	IF VHARGA > 0 THEN
		RETURN VHARGA;
	ELSE
		RETURN 0;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
