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

-- Dumping structure for event layanan.executeBatalOrderResepExpired
DROP EVENT IF EXISTS `executeBatalOrderResepExpired`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` EVENT `executeBatalOrderResepExpired` ON SCHEDULE EVERY 1 DAY STARTS '2023-03-08 00:10:00' ON COMPLETION PRESERVE DISABLE DO BEGIN
	DECLARE VHARI CHAR(10);
	SELECT VALUE INTO VHARI FROM aplikasi.properti_config
	WHERE ID = 61;
	IF VHARI != 'FALSE' THEN
		CALL layanan.executeBatalOrderResep(DATE_ADD(NOW(), INTERVAL -VHARI DAY));
	END IF;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;