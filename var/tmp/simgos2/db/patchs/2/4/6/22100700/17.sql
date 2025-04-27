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
-- Dumping structure for trigger kemkes-ihs.encounter_before_insert
DROP TRIGGER IF EXISTS `encounter_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `encounter_before_insert` BEFORE INSERT ON `encounter` FOR EACH ROW BEGIN
	DECLARE VSEND TINYINT DEFAULT 0;
	DECLARE VSTATUS, VFOUND TINYINT;
	DECLARE VDESKSTATUS CHAR(30);
	DECLARE VCLASS, VSUBJECT, VSHIST, VPERIOD, VPARTICIPAN, VLOCATION, VSPROVIDER, VIDENTIFIER JSON;
	
	/* GET STATUS */
	SELECT `getStatusPendaftaran`(NEW.refId) INTO VDESKSTATUS;
	
	/* GET STATUS HISTORI */
	SELECT getStatusHistory(NEW.refId) INTO VSHIST;
	
	/* GET CLASS */
	SELECT `kemkes-ihs`.getObJectReference(1, 1) INTO VCLASS;
	
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
		
	/* GET PENDAFTARAN */
	SELECT 
	 COUNT(*), 
	 `kemkes-ihs`.`getPatient`(p.NORM), 
	 `kemkes-ihs`.getPeriode(NEW.refId)
	 INTO 
	 VFOUND, 
	 VSUBJECT, 
	 VPERIOD
	 FROM `kemkes-ihs`.patient pt
	 LEFT JOIN pendaftaran.pendaftaran p ON p.NORM = pt.refId
	WHERE p.NOMOR = NEW.refId;
		
	SELECT COUNT(*),
		IF(pr.id IS NULL, NULL, JSON_ARRAY(
			JSON_OBJECT(
				'type', JSON_ARRAY(
					JSON_OBJECT(
						'coding', JSON_ARRAY(
							`kemkes-ihs`.getObJectReference(2, 1)
						)
					)
				),
				'individual', JSON_OBJECT(
					'reference', CONCAT('Practitioner/',pr.id)
				)
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
	LEFT JOIN pegawai.kartu_identitas ki ON ki.NIP = d.NIP AND ki.JENIS = 1
	LEFT JOIN `kemkes-ihs`.practitioner pr ON pr.refId = ki.NOMOR
	LEFT JOIN `kemkes-ihs`.location l ON l.refId = tp.RUANGAN
	WHERE tp.NOPEN = NEW.refId;
	
	IF VSUBJECT IS NULL OR VPARTICIPAN IS NULL THEN 
		SET NEW.send = 0;
	END IF;
	
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.`status` = VDESKSTATUS;
	SET NEW.class = VCLASS;
	SET NEW.subject = VSUBJECT;
	SET NEW.statusHistory = VSHIST;
	SET NEW.period = VPERIOD;
	SET NEW.participant = VPARTICIPAN;
	SET NEW.location = VLOCATION;
	SET NEW.serviceProvider = VSPROVIDER;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
