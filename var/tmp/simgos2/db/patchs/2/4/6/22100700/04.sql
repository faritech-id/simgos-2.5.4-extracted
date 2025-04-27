-- --------------------------------------------------------
-- Host:                         192.168.137.7
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
USE `kemkes-ihs`;
-- Dumping structure for trigger kemkes-ihs.organization_after_update
DROP TRIGGER IF EXISTS `organization_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `organization_after_update` AFTER UPDATE ON `organization` FOR EACH ROW BEGIN
	DECLARE VIDORG CHAR(36);
	DECLARE VFOUND, VSEND TINYINT DEFAULT 0;
	
	IF NEW.send = 0 AND OLD.send != NEW.send THEN
		SELECT COUNT(*)
		 INTO VFOUND
		 FROM `kemkes-ihs`.location l
		WHERE l.refId = OLD.refId;
		
		IF VFOUND = 0 THEN
			BEGIN 
				DECLARE VTURUNAN CHAR(36);
				DECLARE VPARTOF, VPHISICAL JSON;
				
				SELECT COUNT(*), l.id
				 INTO VFOUND, VTURUNAN 
				 FROM `kemkes-ihs`.location l
				WHERE l.refId = LEFT(NEW.refId, LENGTH(NEW.refId)-2) AND l.id IS NOT NULL;
				
				SET VPHISICAL = JSON_OBJECT(
					'coding',
					JSON_ARRAY(
						JSON_OBJECT(
							'code', IF(LENGTH(NEW.refId) = 5, 'ro', 'si'),
							'display', IF(LENGTH(NEW.refId) = 5, 'Room', 'Site'),
							'system', 'http://terminology.hl7.org/CodeSystem/location-physical-type'
						)
					)
				);
				IF VFOUND > 0 THEN
					IF VTURUNAN IS NOT NULL THEN
						SET VPARTOF = JSON_OBJECT('reference', CONCAT('Location/',VTURUNAN));
						SET VSEND = 1;
					END IF;
				END IF;
				
				INSERT INTO `kemkes-ihs`.location
				  (refId, `status`, `name`, managingOrganization, partOf, physicalType, send) 
				VALUE 
				  (OLD.refId, 1, OLD.`name`, JSON_OBJECT('reference', CONCAT('Organization/',IF(NEW.id IS NULL, OLD.id, NEW.id))), VPARTOF, VPHISICAL, VSEND);
			END;
		END IF;
	END IF;
	IF OLD.id IS NULL AND NEW.id IS NOT NULL THEN
		INSERT INTO aplikasi.automaticexecute(PERINTAH)
		VALUES(CONCAT("UPDATE `kemkes-ihs`.organization SET flag = IF(flag = 1, 0, 1), send = 1 WHERE refId LIKE CONCAT('",OLD.refId,"', '%') AND id IS NULL"));
		
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
