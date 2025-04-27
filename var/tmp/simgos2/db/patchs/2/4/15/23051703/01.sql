USE `inventory`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for function inventory.getStokBarangRuangan
DROP FUNCTION IF EXISTS `getStokBarangRuangan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getStokBarangRuangan`(`PBARANG` INT, `PRUANGAN` CHAR(20)) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VSTOK DECIMAL(60,2);
	DECLARE VROWS INT(5);
	
	SET VROWS = 0;
	
	SELECT 1, b.STOK INTO VROWS, VSTOK
	FROM inventory.barang_ruangan b
	WHERE b.BARANG = PBARANG AND b.RUANGAN = PRUANGAN;
	
	IF VROWS > 0 THEN
		RETURN VSTOK;
	END IF;
	
	RETURN 0;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;