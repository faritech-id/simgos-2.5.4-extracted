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

USE `kemkes`;

-- membuang struktur untuk trigger kemkes.data_kebutuhan_apd_before_update
DROP TRIGGER IF EXISTS `data_kebutuhan_apd_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `data_kebutuhan_apd_before_update` BEFORE UPDATE ON `data_kebutuhan_apd` FOR EACH ROW BEGIN
	IF NEW.jumlah_eksisting != OLD.jumlah_eksisting OR NEW.jumlah != OLD.jumlah OR NEW.jumlah_diterima != OLD.jumlah_diterima THEN
		SET NEW.kirim = 1;
	END IF;
	
	IF NEW.kirim != OLD.kirim AND OLD.kirim = 1 AND NEW.kirim = 0 AND NEW.response != NULL THEN
		SET NEW.tgl_kirim = NOW();
	END IF;
	
	IF NEW.kirim != OLD.kirim AND NEW.kirim = 1 AND OLD.kirim = 0 THEN
		SET NEW.response = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
