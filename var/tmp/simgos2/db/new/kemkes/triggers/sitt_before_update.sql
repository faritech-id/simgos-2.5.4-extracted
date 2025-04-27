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

-- membuang struktur untuk trigger kemkes.sitt_before_update
DROP TRIGGER IF EXISTS `sitt_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `sitt_before_update` BEFORE UPDATE ON `sitt` FOR EACH ROW BEGIN
	DECLARE vtipe TINYINT;
	
	IF NOT NEW.kode_icd_x IS NULL AND NEW.kode_icd_x <> '' AND NEW.kode_icd_x <> OLD.kode_icd_x THEN 
		SELECT tb.TIPE_DIAGNOSIS INTO vtipe
		  FROM kemkes.icd_tb tb
		 WHERE tb.KODE = NEW.kode_icd_x;
		 
		IF FOUND_ROWS() = 0 THEN
			SET vtipe = 0;
		END IF;
		
		SET NEW.tipe_diagnosis = vtipe;
	END IF;
	 
	IF NOT (NEW.kirim != OLD.kirim) THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
