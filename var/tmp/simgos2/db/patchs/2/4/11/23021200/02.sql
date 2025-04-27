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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.hitungPembulatan
DROP PROCEDURE IF EXISTS `hitungPembulatan`;
DELIMITER //
CREATE PROCEDURE `hitungPembulatan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VTOTAL, VPEMBULATAN DECIMAL(60, 2);
		
	SELECT CAST(pc.VALUE AS SIGNED)
	  INTO VPEMBULATAN
	  FROM aplikasi.properti_config pc 
	 WHERE pc.ID = 56;
	 
	IF NOT VPEMBULATAN IS NULL THEN
		SET VTOTAL = ROUND(pembayaran.getTotalTagihanPembayaran(PTAGIHAN));
		
		SET VPEMBULATAN = IF(VTOTAL > 0 AND (VTOTAL % VPEMBULATAN) > 0, (VPEMBULATAN - (VTOTAL % VPEMBULATAN)), 0);
		
		UPDATE pembayaran.tagihan t
	   	SET t.PEMBULATAN = VPEMBULATAN
	 	 WHERE t.ID = PTAGIHAN; 
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
