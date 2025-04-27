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

-- Dumping structure for trigger kemkes-ihs.allergy_intolerance_before_update
DROP TRIGGER IF EXISTS `allergy_intolerance_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `allergy_intolerance_before_update` BEFORE UPDATE ON `allergy_intolerance` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VCLINICALSTATUS, VVERIVICATION, VCODE, VCATEGORY, VRECORDING, VSUBJECT, VENCT JSON;
	DECLARE VDATE VARCHAR(50);
	
	SELECT 
	   JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', CONCAT(NEW.refId)
		),
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(61, 1)
			)
		),
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(62, 1)
			)
		)
		INTO 
	  VIDENTIFIER,
	  VCLINICALSTATUS,
	  VVERIVICATION
	  FROM `kemkes-ihs`.organization org,
	  	`kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	  AND org.id IS NOT NULL
	  AND c.id = 60;
	  
	SELECT 
		`kemkes-ihs`.getPatient(p.NORM),
		`kemkes-ihs`.getEncounter(p.NOMOR),
		`dateFormatUTC`(ra.TANGGAL, 1),
		IF( `kemkes-ihs`.getPractitioner(usr.NIP) IS NOT NULL,
			`kemkes-ihs`.getPractitioner(usr.NIP)
		, NULL),
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				ra.KODE_REFERENSI
			),
			'text', ra.DESKRIPSI
		),
		JSON_ARRAY(
			tcr.code
		)
		INTO
		VSUBJECT,
		VENCT,
		VDATE,
		VRECORDING,
		VCODE,
		VCATEGORY
	FROM medicalrecord.riwayat_alergi ra
	LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = ra.KUNJUNGAN
	LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
	LEFT JOIN aplikasi.pengguna usr ON usr.ID = ra.OLEH
	LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.id = ra.JENIS AND tcr.type = 63
	WHERE ra.ID = OLD.refId;
	
	IF VENCT IS NULL OR VENCT IS NULL THEN
		SET NEW.send = 0;
	END IF;
	  
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.clinicalStatus = VCLINICALSTATUS;
	SET NEW.verificationStatus = VVERIVICATION;
	SET NEW.code = VCODE;
	SET NEW.category = VCATEGORY;
	SET NEW.recorder = VRECORDING;
	SET NEW.encounter = VENCT;
	SET NEW.patient = VSUBJECT;
	SET NEW.recordedDate = VDATE;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
