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

-- membuang struktur untuk trigger inventory.penerimaan_barang_after_update
DROP TRIGGER IF EXISTS `penerimaan_barang_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `penerimaan_barang_after_update` AFTER UPDATE ON `penerimaan_barang` FOR EACH ROW BEGIN
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 2 THEN
		UPDATE inventory.penerimaan_barang_detil
		   SET STATUS = 2
		 WHERE PENERIMAAN = OLD.ID
		   AND STATUS = 1;
	END IF;
	
	
	IF OLD.STATUS != NEW.STATUS AND OLD.STATUS = 2 AND NEW.STATUS = 1 THEN
		IF EXISTS(SELECT 1 FROM inventory.pembatalan_penerimaan_barang WHERE PENERIMAAN_BARANG = OLD.ID AND JENIS = 1 AND STATUS = 1) THEN
			UPDATE inventory.pembatalan_penerimaan_barang
			   SET STATUS = 2
			 WHERE PENERIMAAN_BARANG = OLD.ID
			   AND JENIS = 1
			   AND STATUS = 1;
			   
			UPDATE inventory.penerimaan_barang_detil
			   SET STATUS = 1
			 WHERE PENERIMAAN = OLD.ID
			   AND STATUS = 2;						
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
