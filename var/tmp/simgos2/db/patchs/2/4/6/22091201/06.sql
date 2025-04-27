USE `layanan`;
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

-- Dumping structure for trigger layanan.bon_sisa_farmasi_before_update
DROP TRIGGER IF EXISTS `bon_sisa_farmasi_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `bon_sisa_farmasi_before_update` BEFORE UPDATE ON `bon_sisa_farmasi` FOR EACH ROW BEGIN
	DECLARE VJMLLYN INT(11);
	
	IF OLD.STATUS = 1 AND NEW.STATUS = 0 THEN
		SELECT COUNT(*) 
		  INTO VJMLLYN 
		  FROM layanan.layanan_bon_sisa_farmasi l
		 WHERE l.REF = OLD.ID 
		   AND l.`STATUS` = 1 
		 LIMIT 1;
		
		IF VJMLLYN > 0 THEN
			SET NEW.STATUS = OLD.STATUS;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;