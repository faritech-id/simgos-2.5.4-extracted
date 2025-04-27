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

-- Dumping structure for trigger kemkes-ihs.composition_before_insert
DROP TRIGGER IF EXISTS `composition_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `composition_before_insert` BEFORE INSERT ON `composition` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VTYPE, VKATEGORI, VSUBJECT, VENCT, VAUTH, VCUSTODIAN, VSECTION JSON;
	DECLARE VSTATUS CHAR(50);
	DECLARE VDATE, VTITLE VARCHAR(50);
	
	SELECT 
	   JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', CONCAT(NEW.refId)
		),
		tcr.code,
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(37, 1)
			)
		),
		JSON_ARRAY(
			JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(38, 1)
				)
			)
		),
		JSON_OBJECT(
			'reference', CONCAT('Organization/',org.id)
		)
		INTO 
	  VIDENTIFIER,
	  VSTATUS,
	  VTYPE, 
	  VKATEGORI,
	  VCUSTODIAN
	  FROM `kemkes-ihs`.organization org, 
	  	`kemkes-ihs`.code_reference c,
	  	`kemkes-ihs`.type_code_reference tcr
	WHERE org.refId = 1 
	  AND org.id IS NOT NULL
	  AND c.id = 35
	  AND tcr.type = 36
	  AND tcr.id = 2;
	  
	SELECT 
		`kemkes-ihs`.getPatient(p.NORM),
		`kemkes-ihs`.getEncounter(p.NOMOR),
		`dateFormatUTC`(epk.TANGGAL, 1),
		IF( `kemkes-ihs`.getPractitioner(usr.NIP) IS NOT NULL,
			JSON_ARRAY(
				`kemkes-ihs`.getPractitioner(usr.NIP)
			)
		, NULL),
		'Resume Medis Rawat Jalan',
		JSON_ARRAY(
			JSON_OBJECT(
				'code', JSON_OBJECT(
					'coding', JSON_ARRAY(
						`kemkes-ihs`.getObJectReference(41, 1)
					)
				),
				'text', JSON_OBJECT(
					'status', 'additional',
					'div', 'Telah dilakukan edukasi diet'
				)
			)
		)
		INTO
		VSUBJECT,
		VENCT,
		VDATE,
		VAUTH,
		VTITLE,
		VSECTION
	FROM medicalrecord.edukasi_pasien_keluarga epk
	LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = epk.KUNJUNGAN
	LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
	LEFT JOIN aplikasi.pengguna usr ON usr.ID = epk.OLEH
	WHERE epk.ID = NEW.refId;
	
	IF VENCT IS NULL THEN
		SET NEW.send = 0;
	END IF;
	  
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.status = VSTATUS;
	SET NEW.type = VTYPE;
	SET NEW.category = VKATEGORI;
	SET NEW.subject = VSUBJECT;
	SET NEW.encounter = VENCT;
	SET NEW.date = VDATE;
	SET NEW.author = VAUTH;
	SET NEW.title = VTITLE;
	SET NEW.custodian = VCUSTODIAN;
	SET NEW.section = VSECTION;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
