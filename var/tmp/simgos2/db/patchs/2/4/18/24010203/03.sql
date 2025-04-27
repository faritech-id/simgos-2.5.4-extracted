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

-- Dumping structure for trigger kemkes-ihs.encounter_before_update
DROP TRIGGER IF EXISTS `encounter_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `encounter_before_update` BEFORE UPDATE ON `encounter` FOR EACH ROW BEGIN
	DECLARE VSEND TINYINT DEFAULT 0;
	DECLARE VSTATUS, VFOUND TINYINT;
	DECLARE VDESKSTATUS CHAR(30);
	DECLARE VSHIST, VPERIOD, VPARTICIPAN, VDIAGNOSTIC, VSUBJECT, VLOCATION, VSPROVIDER, VIDENTIFIER JSON;
	
	IF NEW.send = 1 AND OLD.send != NEW.send THEN
		SELECT 
		 JSON_OBJECT('reference', CONCAT('Organization/', org.id)),
		 JSON_ARRAY(
		 	JSON_OBJECT(
				'system', CONCAT(c.system, '/', org.id),
				'use', 'official',
				'value', NEW.refId
			)
		 )
		 INTO 
		 VSPROVIDER,
		 VIDENTIFIER
		 FROM `kemkes-ihs`.organization org, `kemkes-ihs`.code_reference c
		WHERE org.refId = 1 
		 AND org.id IS NOT NULL
		 AND c.id = 3;
		 
		SELECT `getStatusPendaftaran`(OLD.refId) INTO VDESKSTATUS;
		
		
		SELECT getStatusHistory(OLD.refId) INTO VSHIST;
		
		SELECT
		 COUNT(*),
		 JSON_ARRAYAGG(
			JSON_OBJECT(
				'condition', JSON_OBJECT(
					'reference', CONCAT('Condition/', co.id),
					'display', JSON_UNQUOTE(JSON_EXTRACT(co.code, '$.coding[0].display'))
				),
				'use', JSON_OBJECT(
					'coding', JSON_ARRAY(`kemkes-ihs`.getObJectReference(4, 1))
				),
				'rank', diag.UTAMA				
			)
		)
		INTO
		 VFOUND,
		 VDIAGNOSTIC
		 FROM `kemkes-ihs`.`condition` co		 
		LEFT JOIN medicalrecord.diagnosa diag ON diag.ID = co.refId
		WHERE co.nopen = OLD.refId AND co.id IS NOT NULL;
		
		SELECT 
		 COUNT(*), 
		 `kemkes-ihs`.`getPatient`(p.NORM),
		 `kemkes-ihs`.getPeriode(OLD.refId)
		 INTO 
		 VFOUND, 
		 VSUBJECT, 
		 VPERIOD
		 FROM `kemkes-ihs`.patient pt
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NORM = pt.refId
		WHERE p.NOMOR = OLD.refId;
			
		SELECT COUNT(*),
			IF(`kemkes-ihs`.getPractitioner(d.NIP) IS NULL, NULL, JSON_ARRAY(
				JSON_OBJECT(
					'type', JSON_ARRAY(
						JSON_OBJECT(
							'coding', JSON_ARRAY(
								`kemkes-ihs`.getObJectReference(2, 1)
							)
						)
					),
					'individual', `kemkes-ihs`.getPractitioner(d.NIP)
				)
			)),
			IF(l.id IS NULL, l.id, JSON_ARRAY(
				JSON_OBJECT(
					'location', JSON_OBJECT(
						'reference', CONCAT('Location/', l.id),
						'display', l.`name`
					)
				)
			))
			INTO 
			VFOUND, 
			VPARTICIPAN,
			VLOCATION
		FROM pendaftaran.tujuan_pasien tp
		LEFT JOIN `master`.dokter d ON d.ID = tp.DOKTER
		LEFT JOIN `kemkes-ihs`.location l ON l.refId = tp.RUANGAN
		WHERE tp.NOPEN = OLD.refId;
		
		IF VSUBJECT IS NULL OR VPARTICIPAN IS NULL THEN 
			SET NEW.send = 0;
		END IF;
			
		SET NEW.`status` = VDESKSTATUS;
		SET NEW.diagnosis = VDIAGNOSTIC;
		SET NEW.statusHistory = VSHIST;
		SET NEW.period = VPERIOD;
		SET NEW.participant = VPARTICIPAN;
		SET NEW.location = VLOCATION;
		SET NEW.subject = VSUBJECT;
		SET NEW.serviceProvider = VSPROVIDER;
		SET NEW.identifier = VIDENTIFIER;
	END IF;	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
