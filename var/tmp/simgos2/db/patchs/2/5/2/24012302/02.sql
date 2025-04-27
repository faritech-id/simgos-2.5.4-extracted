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

-- Dumping structure for trigger kemkes-ihs.location_before_update
DROP TRIGGER IF EXISTS `location_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `location_before_update` BEFORE UPDATE ON `location` FOR EACH ROW BEGIN
	DECLARE VIDORG CHAR(36);
	DECLARE VFOUND, VSEND, VSTATUS TINYINT DEFAULT 0;
	
	DECLARE VTURUNAN CHAR(36);
	DECLARE VPARTOF, VPHISICAL JSON;
	
	SELECT r.STATUS INTO VSTATUS FROM `master`.ruangan r WHERE r.ID = OLD.refId;
	
	SET NEW.status = VSTATUS;
	
	SELECT COUNT(*), l.id
	 INTO VFOUND, VTURUNAN 
	 FROM `kemkes-ihs`.location l
	WHERE l.refId = LEFT(OLD.refId, LENGTH(OLD.refId)-2) AND l.id IS NOT NULL;
	
	IF VFOUND > 0 THEN
		IF VTURUNAN IS NOT NULL THEN
			SET NEW.partOf = JSON_OBJECT('reference', CONCAT('Location/',VTURUNAN));
		ELSE
			SET NEW.send = 0;
		END IF;
	ELSE 
		IF OLD.refId != '1' THEN 
			SET NEW.send = 0;
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
