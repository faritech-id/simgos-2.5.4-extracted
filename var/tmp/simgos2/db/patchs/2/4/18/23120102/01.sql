-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.5.0.6677
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

-- membuang struktur untuk function inventory.getHargaBeli
DROP FUNCTION IF EXISTS `getHargaBeli`;
DELIMITER //
CREATE FUNCTION `getHargaBeli`(
	`PBARANG` INT,
	`PTANGGAL` DATETIME
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VHARGA DECIMAL(60,2);
	
	SELECT ROUND(((d.HARGA - d.DISKON) + (if(b.PPN = 'Ya', 0, (d.HARGA * 11/100)))), 2) INTO VHARGA
	  FROM inventory.penerimaan_barang b, inventory.penerimaan_barang_detil d
	 WHERE d.PENERIMAAN = b.ID AND d.BARANG = PBARANG AND b.TANGGAL_DIBUAT <= PTANGGAL
	 ORDER BY b.TANGGAL_DIBUAT DESC LIMIT 1;
	
	IF VHARGA IS NULL then 
		SET VHARGA = 0;
	END IF; 

    RETURN VHARGA;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
