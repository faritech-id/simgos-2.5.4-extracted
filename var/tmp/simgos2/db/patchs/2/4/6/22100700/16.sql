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
-- Dumping structure for trigger kemkes-ihs.condition_before_insert
DROP TRIGGER IF EXISTS `condition_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `condition_before_insert` BEFORE INSERT ON `condition` FOR EACH ROW BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VSEVERITY VARCHAR(250);
	DECLARE VCSTATUS, VCATEGORI, VCODE, VSUBJECT, VENCOUNTER JSON;
	
	SELECT JSON_OBJECT('coding', JSON_ARRAY(`kemkes-ihs`.getObJectReference(7, 1))) INTO VCSTATUS;
	SELECT JSON_ARRAY(JSON_OBJECT('coding', JSON_ARRAY(`kemkes-ihs`.getObJectReference(5, 1)))) INTO VCATEGORI;
	
	SELECT 
	 p.DIAGNOSA,
	 JSON_OBJECT('coding', 
	   JSON_ARRAY(
		 	JSON_OBJECT(
				'system', 'http://hl7.org/fhir/sid/icd-10',
				'code', p.KODE,
				'display', mrc.STR 	 	 
			)
	   )
	 ),
	 p.NOPEN
	 INTO 
	 VSEVERITY,
	 VCODE,
	 VNOPEN
	 FROM medicalrecord.diagnosa p 
	 LEFT JOIN `master`.mrconso mrc ON mrc.CODE = p.KODE
	 WHERE p.ID = NEW.refId;
	
	/*get Subject and encounter */
	SELECT 
	 e.subject,
	 getEncounter(e.refId)
	 INTO
	 VSUBJECT,
	 VENCOUNTER
	 FROM `kemkes-ihs`.encounter e
	 WHERE e.refId = VNOPEN;
	
	SET NEW.send = IF(VSUBJECT IS NULL, 0, IF(VENCOUNTER IS NULL, 0, 1));
	SET NEW.subject = VSUBJECT;
	SET NEW.encounter = VENCOUNTER;
	SET NEW.clinicalStatus = VCSTATUS;
	SET NEW.code = VCODE;
	SET NEW.nopen = VNOPEN;
	SET NEW.category = VCATEGORI;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
