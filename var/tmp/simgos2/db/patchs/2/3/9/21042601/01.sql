-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk lis
USE `lis`;

-- membuang struktur untuk trigger lis.hasil_log_after_insert
DROP TRIGGER IF EXISTS `hasil_log_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_after_insert` AFTER INSERT ON `hasil_log` FOR EACH ROW BEGIN   
	IF NEW.VENDOR_LIS != 2 THEN
		CALL lis.storeHasilLabToHIS(NEW.ID);		
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.hasil_log_after_update
DROP TRIGGER IF EXISTS `hasil_log_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_after_update` AFTER UPDATE ON `hasil_log` FOR EACH ROW BEGIN
	IF NEW.LIS_HASIL != OLD.LIS_HASIL OR NEW.STATUS = 1 THEN			
		IF NEW.VENDOR_LIS != 2 THEN
			CALL lis.storeHasilLabToHIS(OLD.ID);				
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
