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

-- membuang struktur untuk trigger master.ppk_before_insert
DROP TRIGGER IF EXISTS `ppk_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `ppk_before_insert` BEFORE INSERT ON `ppk` FOR EACH ROW BEGIN
	DECLARE VJENIS TINYINT DEFAULT 2;
	IF NEW.JENIS IS NULL THEN
		IF INSTR(NEW.NAMA, 'RS ') > 0
			OR INSTR(NEW.NAMA, 'RS.') > 0
			OR INSTR(NEW.NAMA, 'RUMAH') > 0
			OR INSTR(NEW.NAMA, 'RSK') > 0
			OR INSTR(NEW.NAMA, 'RSU') > 0 THEN
			SET VJENIS = 1;
		END IF;		
		IF INSTR(NEW.NAMA, 'KLINIK') > 0 THEN
			SET VJENIS = 3;
		END IF;
		IF VJENIS != 1 THEN
			IF INSTR(NEW.NAMA, 'dr.') > 0
				OR INSTR(NEW.NAMA, 'DR.') > 0 
				OR INSTR(NEW.NAMA, ', DR') > 0 
				OR INSTR(NEW.NAMA, 'DR ') > 0
				OR INSTR(NEW.NAMA, 'DRG.') > 0
				OR INSTR(NEW.NAMA, ', dr') > 0 THEN
				SET VJENIS = 4;
			END IF;
		END IF;
	
		SET NEW.JENIS = VJENIS;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
