-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
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

-- Dumping structure for trigger kemkes-ihs.observation_before_update
DROP TRIGGER IF EXISTS `observation_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `observation_before_update` BEFORE UPDATE ON `observation` FOR EACH ROW BEGIN
	DECLARE VENCOUNTER, VSUBJECT, VPERVORMER JSON;
	SELECT
		`kemkes-ihs`.getEncounter(OLD.nopen),
		e.subject
	INTO 
		VENCOUNTER,
		VSUBJECT
	FROM 
		`kemkes-ihs`.encounter e
	WHERE e.refId = OLD.nopen;	
	
	IF VENCOUNTER IS NULL OR VSUBJECT IS NULL THEN
		SET NEW.send = 0;
	END IF;
	
	SET NEW.encounter = VENCOUNTER;
	SET NEW.subject = VSUBJECT;
	
	IF NEW.jenis <= 5 THEN
		SELECT 
			IF(ki.ID IS NOT NULL, JSON_ARRAY(`kemkes-ihs`.`getPractitioner`(ki.NIP)), NULL) INTO VPERVORMER
		FROM medicalrecord.tanda_vital tv 
		LEFT JOIN aplikasi.pengguna pen ON pen.ID = tv.OLEH
		LEFT JOIN pegawai.kartu_identitas ki ON ki.NIP = pen.NIP AND ki.JENIS = 1
		WHERE tv.ID = NEW.refId LIMIT 1;
		
		IF VPERVORMER IS NULL THEN
			SET NEW.send = 0;
		ELSE
			SET NEW.performer = VPERVORMER;
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
