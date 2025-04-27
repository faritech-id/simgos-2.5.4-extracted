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

-- Dumping structure for trigger kemkes-ihs.medication_after_update
DROP TRIGGER IF EXISTS `medication_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `medication_after_update` AFTER UPDATE ON `medication` FOR EACH ROW BEGIN
	IF NEW.send = 0 AND OLD.send = 1 AND NEW.id IS NOT NULL AND OLD.jenis = 1 THEN
		IF EXISTS (SELECT * FROM `kemkes-ihs`.medication_request mr WHERE mr.refId = OLD.refId AND mr.barang = OLD.barang AND mr.group_racikan = OLD.group_racikan) THEN
			UPDATE `kemkes-ihs`.medication_request SET send = 1 WHERE refId = OLD.refId AND barang = OLD.barang AND group_racikan = OLD.group_racikan; 
		ELSE
			INSERT INTO `kemkes-ihs`.medication_request (refId, barang, group_racikan, status_racikan)
			VALUES (OLD.refId, OLD.barang, OLD.group_racikan, OLD.status_racikan);
		END IF;		
	ELSEIF NEW.send = 0 AND OLD.send = 1 AND NEW.id IS NOT NULL AND OLD.jenis = 2 THEN
		IF EXISTS (SELECT * FROM `kemkes-ihs`.medication_dispanse mr WHERE mr.refId = OLD.refId AND mr.barang = OLD.barang AND mr.group_racikan = OLD.group_racikan) THEN
			UPDATE `kemkes-ihs`.medication_dispanse SET send = 1 WHERE refId = OLD.refId AND barang = OLD.barang AND group_racikan = OLD.group_racikan; 
		ELSE
			INSERT INTO `kemkes-ihs`.medication_dispanse (refId, barang, group_racikan, status_racikan)
			VALUES (OLD.refId, OLD.barang, OLD.group_racikan, OLD.status_racikan);
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
