-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
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

-- Dumping structure for function inventory.getHargaJual
DROP FUNCTION IF EXISTS `getHargaJual`;
DELIMITER //
CREATE FUNCTION `getHargaJual`(
	`PBARANG` INT,
	`PHARGABARANG` INT,
	`PMARGIN` INT,
	`PPPN` INT
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	
	DECLARE VHARGA DECIMAL(60,2);
	
	SELECT (hb.HARGA_JUAL  
			  		+ (hb.HARGA_JUAL * IF(PMARGIN IS NULL OR PMARGIN=0, 0, (SELECT mf.MARGIN FROM `master`.margin_penjamin_farmasi mf WHERE mf.ID=PMARGIN LIMIT 1) / 100)) 
					+ ((hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(PMARGIN IS NULL OR PMARGIN=0, 0
							, (SELECT mf.MARGIN FROM `master`.margin_penjamin_farmasi mf WHERE mf.ID=PMARGIN LIMIT 1) / 100))) * IF(PPPN IS NULL OR PPPN=0, 0, (SELECT pn.PPN FROM penjualan.ppn_penjualan pn WHERE pn.ID=PPPN LIMIT 1) / 100))
					) INTO VHARGA
	FROM  inventory.harga_barang hb
	WHERE hb.BARANG=PBARANG AND hb.ID=PHARGABARANG
	LIMIT 1;

	IF FOUND_ROWS() > 0 then 
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
