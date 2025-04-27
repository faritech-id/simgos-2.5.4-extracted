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

-- membuang struktur untuk procedure master.getTarifDiskon
DROP PROCEDURE IF EXISTS `getTarifDiskon`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getTarifDiskon`(
	IN `PJENIS` SMALLINT,
	IN `PTANGGAL` DATETIME,
	OUT `PPERSENTASE` TINYINT,
	OUT `PDISKON` DECIMAL(60, 2)
)
BEGIN
	SELECT d.PERSENTASE, d.TOTAL INTO PPERSENTASE, PDISKON
	  FROM `master`.diskon d
	 WHERE d.JENIS = PJENIS
	   AND d.TANGGAL_SK <= PTANGGAL
	 ORDER BY TANGGAL DESC LIMIT 1;
	
	IF FOUND_ROWS() = 0 THEN 
		SELECT d.PERSENTASE, d.TOTAL INTO PPERSENTASE, PDISKON
		  FROM `master`.diskon d
		 WHERE d.JENIS = PJENIS		 	
		   AND d.STATUS = 1
		 ORDER BY TANGGAL DESC LIMIT 1;	
	END IF;
	 
	IF FOUND_ROWS() = 0 THEN
		SET PPERSENTASE = 0;
		SET PDISKON = 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
