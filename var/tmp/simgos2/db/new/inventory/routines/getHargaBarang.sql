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

-- membuang struktur untuk procedure inventory.getHargaBarang
DROP PROCEDURE IF EXISTS `getHargaBarang`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getHargaBarang`(
	IN `PBARANG` SMALLINT,
	OUT `PTARIF_ID` INT,
	OUT `PTARIF` DECIMAL(60,2),
	IN `PTANGGAL` DATE
)
BEGIN
	SELECT ID, HARGA_JUAL INTO PTARIF_ID, PTARIF 
	  FROM `inventory`.harga_barang
	 WHERE BARANG = PBARANG AND MASA_BERLAKU <= PTANGGAL
	  
	 ORDER BY MASA_BERLAKU DESC, ID DESC LIMIT 1;
	 
	IF FOUND_ROWS() = 0 THEN
		SET PTARIF_ID = NULL;
		SET PTARIF = 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
