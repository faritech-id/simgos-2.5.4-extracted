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

-- Dumping structure for trigger kemkes-ihs.service_request_before_update
DROP TRIGGER IF EXISTS `service_request_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `service_request_before_update` BEFORE UPDATE ON `service_request` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VSUBJECT, VENCOUNTER, VREQUESTER, VREASONCODE, VPERFORM, VCODE JSON;
	DECLARE VSTATUS, VINTENT, VPRIORITY, VOCCRENCEDT, VAUTHON VARCHAR(50);
	
	SELECT 
	 JSON_ARRAY(
	 	JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', OLD.refId
		)
	 )
	 INTO
	 VIDENTIFIER
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 45;
	 
	SELECT
	 tcr.code
	 INTO
	 VSTATUS	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 46 
	 AND tcr.id = 2;
	 
	SELECT
	 tcr.code
	 INTO
	 VINTENT	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 47 
	 AND tcr.id = 5;
	 
	SELECT
	 tcr.code
	 INTO
	 VPRIORITY	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 49 
	 AND tcr.id = 1;
	 
	SELECT 
	  `kemkes-ihs`.getPatient(pen.NORM)
	  , `kemkes-ihs`.getEncounter(pen.NOMOR)
	  , `dateFormatUTC`(ol.TANGGAL, 1)
	  , `dateFormatUTC`(ol.TANGGAL, 1)
	  , `kemkes-ihs`.getPractitioner(dok.NIP)
	  , IF(ol.KETERANGAN IS NOT NULL, JSON_ARRAY(
	  		JSON_OBJECT(
				'text', ol.KETERANGAN
			)
	  ), NULL),
	  (
	  	   SELECT JSON_ARRAYAGG(IF(ref.REF_ID = 4, 
					`kemkes-ihs`.getPractitioner(dok.NIP), 
					IF(ref.REF_ID = 6, 
						`kemkes-ihs`.getPractitioner(per.NIP), 
						IF(ref.REF_ID NOT IN (6,4), 
							`kemkes-ihs`.getPractitioner(peg.NIP), 
							NULL
						)
					)
				)
			) 	PRACTISIONER
			FROM layanan.petugas_tindakan_medis t 
			LEFT JOIN master.referensi ref ON t.JENIS = ref.ID AND ref.JENIS = 32
			LEFT JOIN `master`.dokter dok ON dok.ID = t.MEDIS
			LEFT JOIN `master`.perawat per ON per.ID = t.MEDIS
			LEFT JOIN `master`.pegawai peg ON peg.ID = t.MEDIS
			WHERE t.TINDAKAN_MEDIS = OLD.refId
			AND IF(ref.REF_ID = 4, 
				`kemkes-ihs`.getPractitioner(dok.NIP), 
				IF(ref.REF_ID = 6, 
					`kemkes-ihs`.getPractitioner(per.NIP), 
					IF(ref.REF_ID NOT IN (6,4), 
						`kemkes-ihs`.getPractitioner(peg.NIP), 
						NULL
					)
				)
			) IS NOT NULL
	   ),
	   `kemkes-ihs`.getLoincDeskription(tm.TINDAKAN)
	  INTO
	  VSUBJECT
	  , VENCOUNTER
	  , VOCCRENCEDT
	  , VAUTHON
	  , VREQUESTER
	  , VREASONCODE
	  , VPERFORM
	  , VCODE
	 FROM layanan.tindakan_medis tm 
	 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = tm.KUNJUNGAN
	 LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = k.NOPEN
	 LEFT JOIN layanan.order_lab ol ON ol.NOMOR = k.REF
	 LEFT JOIN `master`.dokter dok ON dok.ID = ol.DOKTER_ASAL
	WHERE tm.ID = OLD.refId 
	 AND pen.NOMOR = OLD.nopen LIMIT 1;
	
	IF VPERFORM IS NULL OR VENCOUNTER IS NULL THEN
		SET NEW.send = 0;
	END IF;
	
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.status = VSTATUS;
	SET NEW.intent = VINTENT;
	SET NEW.priority = VPRIORITY;
	SET NEW.subject = VSUBJECT;
	SET NEW.encounter = VENCOUNTER;
	SET NEW.occurrenceDateTime = VOCCRENCEDT;
	SET NEW.authoredOn = VAUTHON;
	SET NEW.requester = VREQUESTER;
	SET NEW.reasonCode = VREASONCODE;
	SET NEW.performer = VPERFORM;
	SET NEW.code = VCODE;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
