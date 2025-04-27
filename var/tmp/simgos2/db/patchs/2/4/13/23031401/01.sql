-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk informasi
USE `informasi`;

-- membuang struktur untuk event informasi.runExecuteTempatTidur
DROP EVENT IF EXISTS `runExecuteTempatTidur`;
DELIMITER //
CREATE EVENT `runExecuteTempatTidur` ON SCHEDULE EVERY 1 MINUTE STARTS '2020-01-30 08:29:18' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	DECLARE VSUCCESS TINYINT DEFAULT TRUE;
	
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
		CALL informasi.executeTempatTidurTerisiTapiKosong();
	END;
	
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
		CALL informasi.executeTempatTidurDipesanTapiTdkDigunakan();
	END;
	
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
		CALL informasi.executeBedMonitorKemkes(DATE(NOW()), DATE(NOW()));
	END;
	
	
	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
