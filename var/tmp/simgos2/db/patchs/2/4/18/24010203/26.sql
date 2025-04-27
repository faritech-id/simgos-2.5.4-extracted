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

-- Dumping structure for procedure kemkes-ihs.hasilLabToObservation
DROP PROCEDURE IF EXISTS `hasilLabToObservation`;
DELIMITER //
CREATE PROCEDURE `hasilLabToObservation`(
	IN `PTINDAKAN` CHAR(11)
)
BEGIN
	DECLARE VCATEGORY JSON;
	DECLARE VSTATUS VARCHAR(130);
	DECLARE VID CHAR(12); 
	DECLARE VIDPARAMETER INT;
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	
	DECLARE CR_TANDAVITAL CURSOR FOR
		SELECT DISTINCT 
			hl.ID
			, hl.PARAMETER_TINDAKAN
		  FROM layanan.hasil_lab hl
		  LEFT JOIN `master`.parameter_tindakan_lab ptl ON ptl.ID = hl.PARAMETER_TINDAKAN
		 WHERE hl.TINDAKAN_MEDIS = PTINDAKAN;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	
	
	SET VCATEGORY = JSON_ARRAY(
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(9, 2)
			)
		)
	);	
	 
	SELECT
	 tcr.code
	 INTO
	 VSTATUS	
	 FROM `kemkes-ihs`.type_code_reference tcr
	WHERE tcr.type = 54 
	 AND tcr.id = 3;
			
	OPEN CR_TANDAVITAL;
	EOF: LOOP
		FETCH CR_TANDAVITAL INTO VID, VIDPARAMETER;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 6) THEN
			BEGIN
				DECLARE VIDENTIFIER, VBASEDON, VSPECIMEN, VSUBJECT, VENCOUNTER, VCODE, VPERFORMER, VVALQUANTITY JSON;
				DECLARE VISSUED VARCHAR(130);
				DECLARE VVALSTRING VARCHAR(250);
				DECLARE VNOPEN CHAR(11);
				
				SELECT 
					JSON_ARRAY(
						JSON_OBJECT(
							'system', CONCAT(c.system, '/', org.id),
							'value', VID
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
					, JSON_OBJECT(
						'reference', CONCAT('Specimen/',sp.id)
					)
					, `kemkes-ihs`.getPatient(pen.NORM)
					, `kemkes-ihs`.getEncounter(pen.NOMOR)
					, `kemkes-ihs`.getParameterHasilLoincDeskription(hl.PARAMETER_TINDAKAN)
					, `dateFormatUTC`(kjgn.FINAL_HASIL_TANGGAL, 1)
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
				   , IF(tcr.id IS NOT NULL,
						IF(hl.HASIL REGEXP '^[0-9]+\\.?[0-9]*$',
							JSON_OBJECT(
								'value', CAST(hl.HASIL AS DECIMAL(10,2))
								, 'unit', tcr.display
								, 'system', cr.system
								, 'code', tcr.code
							), NULL 
						), NULL
					),
					IF(hl.HASIL REGEXP '^[0-9]+\\.?[0-9]*$',
						NULL, hl.HASIL 
					)
					, pen.NOMOR
					INTO
					VBASEDON
					, VSPECIMEN
					, VSUBJECT
					, VENCOUNTER
					, VCODE
					, VISSUED
					, VPERFORMER
					, VVALQUANTITY
					, VVALSTRING
					, VNOPEN
				  FROM layanan.hasil_lab hl
				  LEFT JOIN `kemkes-ihs`.service_request sr ON sr.refId = hl.TINDAKAN_MEDIS
				  LEFT JOIN `kemkes-ihs`.specimen sp ON sp.refId = hl.TINDAKAN_MEDIS
				  LEFT JOIN `master`.parameter_tindakan_lab ptl ON ptl.ID = hl.PARAMETER_TINDAKAN
				  LEFT JOIN `kemkes-ihs`.satuan_lab_to_ut sltu ON sltu.SATUAN_LAB = ptl.SATUAN
				  LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.id = sltu.UNIT_TERM AND tcr.`type` = 55
				  LEFT JOIN `kemkes-ihs`.code_reference cr ON cr.id = tcr.`type` 
				  LEFT JOIN layanan.tindakan_medis tm ON tm.ID = hl.TINDAKAN_MEDIS
				  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
				  LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = kjgn.NOPEN
				 WHERE hl.ID = VID AND sr.id IS NOT NULL LIMIT 1;
				
				INSERT INTO `kemkes-ihs`.observation(refId, jenis, identifier, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, issued, performer, specimen, basedOn, valueString, send)
				   VALUES (VID, 6, VIDENTIFIER, VSTATUS, VVALQUANTITY, VCATEGORY, VNOPEN, VCODE, VSUBJECT, VISSUED, VENCOUNTER, VISSUED, VPERFORMER, VSPECIMEN, VBASEDON, VVALSTRING, 1);
			END;
		END IF;
		
		
	END LOOP;
	CLOSE CR_TANDAVITAL;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
