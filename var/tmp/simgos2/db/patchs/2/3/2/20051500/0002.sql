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

USE `informasi`;

-- membuang struktur untuk event informasi.runExecuteTempatTidur
DROP EVENT IF EXISTS `runExecuteTempatTidur`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` EVENT `runExecuteTempatTidur` ON SCHEDULE EVERY 1 MINUTE STARTS '2020-01-30 08:29:18' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	CALL informasi.executeTempatTidurTerisiTapiKosong();
	
	CALL informasi.executeTempatTidurDipesanTapiDigunakan();
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
