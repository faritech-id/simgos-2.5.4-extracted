-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for kemkes-ihs
USE `kemkes-ihs`;

-- Dumping structure for trigger kemkes-ihs.service_request_after_update
DROP TRIGGER IF EXISTS `service_request_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `service_request_after_update` AFTER UPDATE ON `service_request` FOR EACH ROW BEGIN
	DECLARE VJENIS INT;
	
	SELECT 
		t.JENIS INTO VJENIS
	FROM layanan.tindakan_medis tm
	LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	WHERE tm.ID = OLD.refId;
	
	IF NEW.send = 0 AND OLD.send != NEW.send AND NEW.id IS NOT NULL THEN
		IF VJENIS = 8 THEN
			IF NOT EXISTS(SELECT * FROM  `kemkes-ihs`.specimen WHERE refId = OLD.refId AND nopen = OLD.nopen) THEN
				INSERT INTO `kemkes-ihs`.specimen (refId, nopen) VALUES (OLD.refId, OLD.nopen);
			ELSE
				UPDATE `kemkes-ihs`.specimen SET send = 1 WHERE refId = OLD.refId;
			END IF;
		ELSEIF VJENIS = 7 THEN
			IF NOT EXISTS(SELECT * FROM  `kemkes-ihs`.imaging_study WHERE refId = OLD.refId AND nopen = OLD.nopen) THEN
				INSERT INTO `kemkes-ihs`.imaging_study (refId, nopen) VALUES (OLD.refId, OLD.nopen);
			ELSE 
				UPDATE `kemkes-ihs`.imaging_study SET `get` = 1 WHERE refId = OLD.refId;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
