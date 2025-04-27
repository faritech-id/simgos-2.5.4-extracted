-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for kemkes-ihs
USE `kemkes-ihs`;

-- Dumping structure for event kemkes-ihs.autoExecuteIhsMaster
DROP EVENT IF EXISTS `autoExecuteIhsMaster`;
DELIMITER //
CREATE EVENT `autoExecuteIhsMaster` ON SCHEDULE EVERY 1 MINUTE STARTS '2022-07-25 20:49:08' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	IF EXISTS(SELECT * FROM aplikasi.integrasi integ WHERE integ.ID = 7 AND integ.`STATUS` = 1) THEN
		CALL `kemkes-ihs`.ruanganToOrganization();	
		CALL `kemkes-ihs`.pasienToPatient();
		CALL `kemkes-ihs`.pegawaiToPractitioner();
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
