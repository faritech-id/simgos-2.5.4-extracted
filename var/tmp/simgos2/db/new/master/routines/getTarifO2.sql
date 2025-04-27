-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure master.getTarifO2
DROP PROCEDURE IF EXISTS `getTarifO2`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getTarifO2`(
	IN `PTANGGAL` DATETIME,
	OUT `PTARIF_ID` INT,
	OUT `PTARIF` INT
)
BEGIN
	SELECT ID, TARIF INTO PTARIF_ID, PTARIF 
	  FROM `master`.tarif_o2 tp
	 WHERE tp.TANGGAL_SK <= PTANGGAL
	 ORDER BY tp.TANGGAL DESC LIMIT 1;
	 
	IF FOUND_ROWS() = 0 THEN
		SELECT ID, TARIF INTO PTARIF_ID, PTARIF 
		  FROM `master`.tarif_o2 tp
		 WHERE tp.STATUS = 1
		 ORDER BY tp.TANGGAL DESC LIMIT 1;
	END IF;
	 
	IF FOUND_ROWS() = 0 THEN
		SET PTARIF_ID = NULL;
		SET PTARIF = 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
