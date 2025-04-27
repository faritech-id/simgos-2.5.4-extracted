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

-- Dumping structure for procedure kemkes-ihs.catatanHasilLabToDignosticReport
DROP PROCEDURE IF EXISTS `catatanHasilLabToDignosticReport`;
DELIMITER //
CREATE PROCEDURE `catatanHasilLabToDignosticReport`(
	IN `PIDHASIL_LAB` CHAR(15)
)
BEGIN
	DECLARE VFOUND INT;
	DECLARE VTINDAKANMEDIS, VNOPEN CHAR(11);
	DECLARE VSTATUS VARCHAR(130) DEFAULT ''; 
	DECLARE VISSUED VARCHAR(130);
	DECLARE VCULCLUSION TEXT;
	DECLARE VIDENTIFIER, VBASEON, VSPESIMEN, VSUBJECT, VENCOUNTER, VCODE, VPERVORMER, VCATEGORI, VOBSERVATION JSON;
	
	SELECT 
		hl.TINDAKAN_MEDIS
		INTO
		VTINDAKANMEDIS
	 FROM layanan.hasil_lab hl 
	 WHERE hl.ID = PIDHASIL_LAB;
	 
	SELECT 
		COUNT(*)
		INTO
		VFOUND
	 FROM `kemkes-ihs`.observation ob 
	  LEFT JOIN layanan.hasil_lab hl ON hl.ID = ob.refId
	 WHERE ob.jenis = 6 AND hl.TINDAKAN_MEDIS = VTINDAKANMEDIS AND ob.id IS NULL;
	
	IF VFOUND = 0 THEN
			SELECT 
				JSON_ARRAY(
					JSON_OBJECT(
						'system', CONCAT(c.system, '/', org.id),
						'use', 'official', 
						'value', VTINDAKANMEDIS
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
				sp.request 
				, JSON_ARRAY(
					JSON_OBJECT(
						'reference', CONCAT('Specimen/', sp.id)
					)
				) 
				, sp.subject
				, sr.encounter
				, JSON_REMOVE(sr.code, '$.text') 
				, tcr.code 
				, `dateFormatUTC`(kjgn.FINAL_HASIL_TANGGAL, 1)
				, IF(`kemkes-ihs`.getPractitioner(dok.NIP) IS NOT NULL, JSON_ARRAY(
					`kemkes-ihs`.getPractitioner(dok.NIP)
				), NULL) performer
				, IF(`kemkes-ihs`.getObJectReference(58, ttl.KATEGORI) IS NOT NULL, JSON_ARRAY(
					JSON_OBJECT(
						'coding', JSON_ARRAY(
							`kemkes-ihs`.getObJectReference(58, ttl.KATEGORI)
						)
					)
				), NULL) 
				, chl.CATATAN 
				, (
					SELECT 
						JSON_ARRAYAGG(
							JSON_OBJECT(
								'reference', CONCAT('Observation/', ob.id)
							)
						)
					FROM `kemkes-ihs`.observation ob 
					LEFT JOIN layanan.hasil_lab hl1 ON hl1.ID = ob.refId
					WHERE ob.jenis = 6 AND hl1.TINDAKAN_MEDIS = hl.ID LIMIT 1
				)
				, kjgn.NOPEN
				INTO
				VBASEON
				, VSPESIMEN
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
				LEFT JOIN `kemkes-ihs`.service_request sr ON sr.refId = hl.ID
				LEFT JOIN `kemkes-ihs`.specimen sp ON sp.refId = hl.ID
				LEFT JOIN layanan.catatan_hasil_lab chl ON chl.KUNJUNGAN = hl.KUNJUNGAN
				LEFT JOIN `kemkes-ihs`.tindakan_to_loinc ttl ON ttl.TINDAKAN = hl.TINDAKAN
				LEFT JOIN `master`.dokter dok ON dok.ID = chl.DOKTER
				LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = hl.KUNJUNGAN
			 , `kemkes-ihs`.type_code_reference tcr
			 WHERE tcr.id = 4
			 AND tcr.`type` = 57 
			 AND hl.ID = VTINDAKANMEDIS;
			
			
			IF VPERVORMER IS NOT NULL THEN
				SET VPERVORMER = JSON_ARRAY_INSERT(VPERVORMER, '$[0]', `kemkes-ihs`.getOrganization('1'));
			END IF;
			
			INSERT INTO `kemkes-ihs`.diagnostic_report (identifier, basedOn, `status`, category, `code`, subject, encounter, effectiveDateTime, issued, performer, specimen, conclusion, result, refId, nopen)
			VALUES (VIDENTIFIER, VBASEON, VSTATUS, VCATEGORI, VCODE, VSUBJECT, VENCOUNTER, VISSUED, VISSUED, VPERVORMER, VSPESIMEN, VCULCLUSION, VOBSERVATION, VTINDAKANMEDIS, VNOPEN);
			 
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
