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

-- Dumping structure for trigger kemkes-ihs.procedure_before_update
DROP TRIGGER IF EXISTS `procedure_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `procedure_before_update` BEFORE UPDATE ON `procedure` FOR EACH ROW BEGIN
	DECLARE VSTATUS CHAR(100);
	DECLARE VCODE, VSUBJECT, VENCOUNTER, VNOTE, VCATEGORI JSON;
	
	SELECT 
		tcr.code,
		JSON_OBJECT('coding', 
		   JSON_ARRAY(
			 	JSON_OBJECT(
					'system', 'http://hl7.org/fhir/sid/icd-9-cm',
					'code', pro.KODE,
					'display', mrc.STR 	 	 
				)
		   )
		),
		`kemkes-ihs`.getPatient(pen.NORM),
		`kemkes-ihs`.getEncounter(pen.NOMOR),
		JSON_ARRAY(
			JSON_OBJECT(
				'text', pro.TINDAKAN
			)
		),
		JSON_OBJECT(
			'coding', JSON_ARRAY(`kemkes-ihs`.getObJectReference(12, 1))
		)
	INTO
		VSTATUS,
		VCODE,
		VSUBJECT,
		VENCOUNTER,
		VNOTE,
		VCATEGORI
	FROM 
		medicalrecord.prosedur pro 
	LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = pro.NOPEN
	LEFT JOIN `master`.mrconso mrc ON mrc.CODE = pro.KODE
	, `kemkes-ihs`.type_code_reference tcr
	WHERE pro.ID = OLD.refId 
	AND tcr.`type` = 11 
	AND tcr.id = 6 LIMIT 1;
	
	IF VSUBJECT IS NULL OR VENCOUNTER IS NULL THEN
		SET NEW.send = 0;
	END IF;
	
	SET NEW.status = VSTATUS;
	SET NEW.code = VCODE;
	SET NEW.subject = VSUBJECT;
	SET NEW.encounter = VENCOUNTER;
	SET NEW.note = VNOTE;
	SET NEW.category = VCATEGORI;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
