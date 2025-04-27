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
-- Dumping structure for trigger kemkes-ihs.organization_before_insert
DROP TRIGGER IF EXISTS `organization_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `organization_before_insert` BEFORE INSERT ON `organization` FOR EACH ROW BEGIN
	DECLARE VNAMA VARCHAR(150);
	DECLARE VFIND TINYINT;
	
	SELECT COUNT(*), r.DESKRIPSI
	 INTO VFIND, VNAMA
	 FROM `master`.ruangan r
	WHERE r.ID = NEW.refId; 
	
	IF VFIND > 0 THEN
		SET NEW.name = VNAMA;
		BEGIN 
			DECLARE VPARTOF CHAR(36);
			SELECT COUNT(*), o.id 
			 INTO VFIND, VPARTOF
			 FROM `kemkes-ihs`.organization o
			WHERE o.refId = LEFT(NEW.refId, LENGTH(NEW.refId)-2) AND o.id IS NOT NULL ;
			
			IF VFIND > 0 THEN
				SET NEW.partOf = JSON_OBJECT('reference', CONCAT('Organization/', VPARTOF));
				
				SET NEW.type = JSON_ARRAY(
					JSON_OBJECT('coding',
						JSON_ARRAY(
							`kemkes-ihs`.getObJectReference(8, 2)
						)
					)
				);	
			ELSE
				SET NEW.send = 0;
			END IF;
			
		END;
	ELSE 
		SET NEW.send = 0;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
