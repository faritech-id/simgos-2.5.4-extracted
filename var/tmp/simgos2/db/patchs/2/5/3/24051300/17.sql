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

-- Dumping structure for procedure kemkes-ihs.catatanHasilRadToDignosticReport
DROP PROCEDURE IF EXISTS `catatanHasilRadToDignosticReport`;
DELIMITER //
CREATE PROCEDURE `catatanHasilRadToDignosticReport`(
	IN `PTINDAKANMEDIS` CHAR(11)
)
BEGIN
	DECLARE VFOUND INT;
	DECLARE VNOPEN CHAR(11);
	DECLARE VSTATUS VARCHAR(130) DEFAULT ''; 
	DECLARE VISSUED VARCHAR(130);
	DECLARE VCULCLUSION TEXT;
	DECLARE VIDENTIFIER, VBASEON, VSPESIMEN, VSUBJECT, VENCOUNTER, VCODE, VPERVORMER, VCATEGORI, VOBSERVATION, VIMAGESTUDY JSON;
	
	SELECT 
		JSON_ARRAY(
			JSON_OBJECT(
				'system', CONCAT(c.system, '/', org.id, '/rad'),
				'use', 'official', 
				'value', PTINDAKANMEDIS
			)
		)
		INTO
		VIDENTIFIER
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	 WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 56 LIMIT 1;
	
	SELECT 
		ob.basedOn
		, ob.derivedFrom
		, sr.subject
		, sr.encounter
		, sr.code
		, tcr.code 
		, `dateFormatUTC`(hrad.TANGGAL, 1)
		, IF(`kemkes-ihs`.getPractitioner(dok.NIP) IS NOT NULL, JSON_ARRAY(
			`kemkes-ihs`.getPractitioner(dok.NIP)
		), NULL) performer
		, JSON_ARRAY(
			JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(58, 24)
				)
			)
		)
		, hrad.HASIL 
		, JSON_ARRAYAGG(
			JSON_OBJECT(
				'reference', CONCAT('Observation/', ob.id)
			)
		)
		, kjgn.NOPEN
		INTO
		VBASEON
		, VIMAGESTUDY
		, VSUBJECT
		, VENCOUNTER
		, VCODE
		, VSTATUS
		, VISSUED
		, VPERVORMER
		, VCATEGORI
		, VCULCLUSION
		, VOBSERVATION
		, VNOPEN
	 FROM layanan.tindakan_medis hl
	 	LEFT JOIN layanan.hasil_rad hrad ON hrad.TINDAKAN_MEDIS = hl.ID
		LEFT JOIN `kemkes-ihs`.service_request sr ON sr.refId = hl.ID
		LEFT JOIN `kemkes-ihs`.imaging_study ims ON ims.refId = hl.ID
		LEFT JOIN `kemkes-ihs`.observation ob ON ob.refId = hl.ID AND ob.jenis = 7
		LEFT JOIN `kemkes-ihs`.tindakan_to_loinc ttl ON ttl.TINDAKAN = hl.TINDAKAN
		LEFT JOIN `master`.dokter dok ON dok.ID = hrad.DOKTER
		LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = hl.KUNJUNGAN
	 , `kemkes-ihs`.type_code_reference tcr
	 WHERE tcr.id = 4
	 AND tcr.`type` = 57 
	 AND hl.ID = PTINDAKANMEDIS;
	
	 
	IF VPERVORMER IS NOT NULL THEN
		SET VPERVORMER = JSON_ARRAY_INSERT(VPERVORMER, '$[0]', `kemkes-ihs`.getOrganization('1'));
	END IF;
	
	IF NOT EXISTS(SELECT * FROM `kemkes-ihs`.diagnostic_report dr WHERE dr.refId = PTINDAKANMEDIS) THEN
		INSERT INTO `kemkes-ihs`.diagnostic_report (identifier, basedOn, `status`, category, `code`, subject, encounter, effectiveDateTime, issued, performer, imagingStudy, conclusion, result, refId, nopen)
		VALUES (VIDENTIFIER, VBASEON, VSTATUS, VCATEGORI, VCODE, VSUBJECT, VENCOUNTER, VISSUED, VISSUED, VPERVORMER, VIMAGESTUDY, VCULCLUSION, VOBSERVATION, PTINDAKANMEDIS, VNOPEN);
	ELSE
		UPDATE `kemkes-ihs`.diagnostic_report SET
			identifier = VIDENTIFIER
			, basedOn = VBASEON
			, `status` = VSTATUS
			, category = VCATEGORI
			, `code` = VCODE
			, subject = VSUBJECT
			, encounter = VENCOUNTER
			, effectiveDateTime = VISSUED
			, issued = VISSUED
			, performer = VPERVORMER
			, imagingStudy = VIMAGESTUDY
			, conclusion = VCULCLUSION
			, result =VOBSERVATION
		WHERE refId = PTINDAKANMEDIS
		AND nopen = VNOPEN;
	END IF;
	 
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
