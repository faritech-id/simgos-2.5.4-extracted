-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
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


-- Dumping database structure for pembayaran
USE `pembayaran`;

-- Dumping structure for function pembayaran.cekGabungTagihanBerdasarkanNopen
DROP FUNCTION IF EXISTS `cekGabungTagihanBerdasarkanNopen`;
DELIMITER //
CREATE FUNCTION `cekGabungTagihanBerdasarkanNopen`(
	`PNOPEN` CHAR(10)
) RETURNS tinyint
    DETERMINISTIC
BEGIN
	DECLARE VTAGIHAN CHAR(10);
	
	SELECT 
		tp.TAGIHAN INTO VTAGIHAN
	FROM pembayaran.tagihan_pendaftaran tp
	WHERE tp.PENDAFTARAN = PNOPEN
	AND tp.`STATUS` = 1;
	
	IF EXISTS(SELECT 1
	  FROM pembayaran.gabung_tagihan gt
	  WHERE (gt.DARI = VTAGIHAN OR gt.KE = VTAGIHAN)
	  AND gt.`STATUS` = 1
	 LIMIT 1) THEN
	 	RETURN 1;
	END IF;
	
	RETURN 0;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
