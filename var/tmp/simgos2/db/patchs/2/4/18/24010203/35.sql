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

-- Dumping structure for trigger kemkes-ihs.specimen_before_insert
DROP TRIGGER IF EXISTS `specimen_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `specimen_before_insert` BEFORE INSERT ON `specimen` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VSUBJECT, VTYPE, VREQUEST JSON;
	DECLARE VSTATUS, VRECEIVEDTIME VARCHAR(130);
	
	SELECT 
	 JSON_ARRAY(
	 	JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'value', NEW.refId,
			'assigner', JSON_OBJECT(
				'reference', CONCAT('Organization/', org.id)
			)
		)
	 )
	 INTO
	 VIDENTIFIER
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 50;
	 
	SELECT
	 tcr.code
	 INTO
	 VSTATUS	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 51 
	 AND tcr.id = 1;
	 
	SELECT 
	  `kemkes-ihs`.getPatient(pen.NORM)
	  , JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(52, ttl.SPESIMENT)
			)
	  )
	  , IF(sr.id IS NOT NULL, JSON_ARRAY(
	  		JSON_OBJECT(
				'reference', CONCAT('ServiceRequest/', sr.id)
			)
	  ), NULL)
	  , `dateFormatUTC`(tm.TANGGAL, 1)
	  INTO
	  VSUBJECT
	  , VTYPE
	  , VREQUEST
	  , VRECEIVEDTIME
	 FROM layanan.tindakan_medis tm 
	 LEFT JOIN `kemkes-ihs`.tindakan_to_loinc ttl ON  ttl.TINDAKAN = tm.TINDAKAN
	 LEFT JOIN `kemkes-ihs`.service_request sr ON sr.refId = tm.ID
	 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = tm.KUNJUNGAN
	 LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = k.NOPEN
	 LEFT JOIN layanan.order_lab ol ON ol.NOMOR = k.REF
	 LEFT JOIN `master`.dokter dok ON dok.ID = ol.DOKTER_ASAL
	WHERE tm.ID = NEW.refId 
	 AND pen.NOMOR = NEW.nopen LIMIT 1;
	 
	IF VSUBJECT IS NULL THEN
		SET NEW.send = 0;
	END IF;
	 
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.status = VSTATUS;
	SET NEW.subject = VSUBJECT;
	SET NEW.type = VTYPE;
	SET NEW.request = VREQUEST;
	SET NEW.receivedTime = VRECEIVEDTIME;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
