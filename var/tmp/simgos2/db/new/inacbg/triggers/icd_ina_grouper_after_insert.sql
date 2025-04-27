-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk trigger inacbg.icd_ina_grouper_after_insert
DROP TRIGGER IF EXISTS `icd_ina_grouper_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `icd_ina_grouper_after_insert` AFTER INSERT ON `icd_ina_grouper` FOR EACH ROW BEGIN
	DECLARE VSAB VARCHAR(15);
	
	SET VSAB = IF(NEW.icd_type = 1, 'ICD10_2020', 'ICD9CM_2020');
	
	IF NOT EXISTS(SELECT 1 FROM `master`.mrconso mc WHERE mc.SAB = VSAB AND mc.TTY = 'PT' AND mc.CODE = NEW.code) THEN
		INSERT INTO `master`.mrconso(SAB, TTY, CODE, STR, VALIDCODE, ACCPDX, CODE_ASTERISK, ASTERISK, IM, ICD_TYPE, VERSION)
		VALUES(VSAB, 'PT', NEW.code, NEW.description, NEW.validcode, NEW.accpdx, NEW.code_asterisk, NEW.asterisk, NEW.im, NEW.icd_type, 6);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
