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

-- Dumping structure for procedure kemkes-ihs.hasilRadToObservation
DROP PROCEDURE IF EXISTS `hasilRadToObservation`;
DELIMITER //
CREATE PROCEDURE `hasilRadToObservation`(
	IN `PTINDAKAN` CHAR(11)
)
BEGIN
	DECLARE VIDENTIFIER, VBASEDON, VSPECIMEN, VSUBJECT, VENCOUNTER, VCODE, VPERFORMER, VVALQUANTITY, VCATEGORY, VDERIVEDFROM JSON;
	DECLARE VSTATUS, VISSUED, VVALSTRING VARCHAR(250);
	DECLARE VNOPEN CHAR(11);
	 
	SELECT
	 tcr.code
	 INTO
	 VSTATUS	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 54 
	 AND tcr.id = 3;
			
	SET VCATEGORY = JSON_ARRAY(
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(9, 3)
			)
		)
	);	
			
	SELECT 
		JSON_ARRAY(
			JSON_OBJECT(
				'system', CONCAT(c.system, '/', org.id),
				'value', PTINDAKAN
			)
		)
		INTO
		VIDENTIFIER
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 53;
				
	SELECT 
		JSON_ARRAY(
			JSON_OBJECT(
				'reference', CONCAT('ServiceRequest/',sr.id)
			)
		)
		, JSON_ARRAY(
			JSON_OBJECT(
				'reference', CONCAT('ImagingStudy/',sp.id)
			)
		)
		, `kemkes-ihs`.getPatient(pen.NORM)
		, `kemkes-ihs`.getEncounter(pen.NOMOR)
		, `kemkes-ihs`.getLoincDeskription(tm.TINDAKAN)
		, `dateFormatUTC`(hl.TANGGAL, 1)
		, (SELECT JSON_ARRAYAGG(IF(ref.REF_ID = 4, 
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
			WHERE t.TINDAKAN_MEDIS = hl.TINDAKAN_MEDIS
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
	   )
	   ,
		IF(hl.HASIL REGEXP '^[0-9]+\\.?[0-9]*$',
			NULL, hl.HASIL 
		)
		, pen.NOMOR
		INTO
		VBASEDON
		, VDERIVEDFROM
		, VSUBJECT
		, VENCOUNTER
		, VCODE
		, VISSUED
		, VPERFORMER
		, VVALSTRING
		, VNOPEN
	  FROM layanan.hasil_rad hl
	  LEFT JOIN `kemkes-ihs`.service_request sr ON sr.refId = hl.TINDAKAN_MEDIS
	  LEFT JOIN `kemkes-ihs`.imaging_study sp ON sp.refId = hl.TINDAKAN_MEDIS
	  LEFT JOIN layanan.tindakan_medis tm ON tm.ID = hl.TINDAKAN_MEDIS
	  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = kjgn.NOPEN
	WHERE hl.TINDAKAN_MEDIS = PTINDAKAN AND sr.id IS NOT NULL LIMIT 1;
	
	IF VPERFORMER IS NOT NULL THEN
		SET VPERFORMER = JSON_ARRAY_INSERT(VPERFORMER, '$[0]', `kemkes-ihs`.getOrganization('1'));
	END IF;
			
	IF NOT EXISTS(SELECT * FROM `kemkes-ihs`.observation WHERE refId = PTINDAKAN AND jenis=7 LIMIT 1) THEN
	INSERT INTO `kemkes-ihs`.observation(refId, jenis, identifier, `status`, category, nopen, `code`, subject, effectiveDateTime, encounter, issued, performer, derivedFrom, basedOn, valueString, send)
	   VALUES (PTINDAKAN, 7, VIDENTIFIER, VSTATUS, VCATEGORY, VNOPEN, VCODE, VSUBJECT, VISSUED, VENCOUNTER, VISSUED, VPERFORMER, VDERIVEDFROM, VBASEDON, VVALSTRING, 1);
	ELSE 
		UPDATE `kemkes-ihs`.observation SET
			identifier = VIDENTIFIER, 
			`status`= VSTATUS, 
			category =VCATEGORY, 
			`code` = VCODE, 
			SUBJECT = VSUBJECT, 
			effectiveDateTime = VISSUED, 
			encounter = VENCOUNTER, 
			issued = VISSUED, 
			performer = VPERFORMER, 
			derivedFrom = VDERIVEDFROM, 
			basedOn = VBASEDON, 
			valueString = VVALSTRING, 
			send = 1
		WHERE refId = PTINDAKAN AND jenis=7;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
