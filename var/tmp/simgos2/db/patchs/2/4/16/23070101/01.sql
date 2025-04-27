-- --------------------------------------------------------
-- Host:                         192.168.137.8
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


-- Dumping database structure for kemkes-ihs
USE `kemkes-ihs`;

-- Dumping structure for procedure kemkes-ihs.tandaVitalToObservation
DROP PROCEDURE IF EXISTS `tandaVitalToObservation`;
DELIMITER //
CREATE PROCEDURE `tandaVitalToObservation`()
BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTGL_INPUT CHAR(150);
	DECLARE VCATEGORY, VCODE, VSUBJECT, VENCOUNTER JSON;
	DECLARE VTANGGAL DATETIME;
	DECLARE VID, VSISTOLIK, VDISTOLIK, VFREKUENSI_NADI, VFREKUENSI_NAFAS, VSUHU, VNORM, VSEND INT;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_TANDAVITAL CURSOR FOR
		SELECT DISTINCT tv.ID, tv.SISTOLIK, tv.DISTOLIK, tv.FREKUENSI_NADI, tv.FREKUENSI_NAFAS, tv.SUHU, pn.NOMOR NOPEN, tv.TANGGAL TANGGAL, DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%Y-%m-%dT%TZ'), pn.NORM
		  FROM `medicalrecord`.tanda_vital tv
		  	 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = tv.KUNJUNGAN
		  	 LEFT JOIN pendaftaran.pendaftaran pn ON pn.NOMOR = kj.NOPEN		  	 
		  	 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pn.NOMOR
			 LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
		      , `kemkes-ihs`.sinkronisasi s
		 WHERE s.ID = 6
		 AND (tv.WAKTU_PEMERIKSAAN IS NOT NULL AND tv.WAKTU_PEMERIKSAAN != '0000-00-00 00:00:00')
		 AND tv.TANGGAL > s.TANGGAL_TERAKHIR
		 AND r.JENIS_KUNJUNGAN = 1
		 ORDER BY tv.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_TANDAVITAL;
	EOF: LOOP
		FETCH CR_TANDAVITAL INTO VID, VSISTOLIK, VDISTOLIK, VFREKUENSI_NADI, VFREKUENSI_NAFAS, VSUHU, VNOPEN, VTANGGAL, VTGL_INPUT, VNORM;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		
		SET VCATEGORY = JSON_ARRAY(
			JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(9, 1)
				)
			)
		);
		
		
		SELECT `kemkes-ihs`.`getPatient`(VNORM) INTO VSUBJECT;
		SELECT `kemkes-ihs`.getEncounter(VNOPEN) INTO VENCOUNTER;
		
		SET VSEND = IF(VSUBJECT IS NULL, 0, IF(VENCOUNTER IS NULL, 0, 1));
		
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 1) THEN
			SET VCODE = JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(10, 1)
				)
			);
			INSERT INTO `kemkes-ihs`.observation(refId, jenis, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, send)
			   VALUES (VID, 1, 'final', JSON_OBJECT(
					'value', VFREKUENSI_NADI,
					'unit', 'beats/minute',
					'system', 'http://unitsofmeasure.org',
					'code', '/min'
				), VCATEGORY, VNOPEN, VCODE, VSUBJECT, VTGL_INPUT, VENCOUNTER, VSEND);
		END IF;
		
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 2) THEN
			SET VCODE = JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(10, 2)
				)
			);
			INSERT INTO `kemkes-ihs`.observation(refId, jenis, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, send)
			   VALUES (VID, 2, 'final', JSON_OBJECT(
					'value', VFREKUENSI_NAFAS,
					'unit', 'breaths/minute',
					'system', 'http://unitsofmeasure.org',
					'code', '/min'
				), VCATEGORY, VNOPEN, VCODE, VSUBJECT, VTGL_INPUT, VENCOUNTER, VSEND);
		END IF;
		
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 3) THEN
			SET VCODE = JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(10, 3)
				)
			);
			INSERT INTO `kemkes-ihs`.observation(refId, jenis, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, send)
			   VALUES (VID, 3, 'final', JSON_OBJECT(
					'value', VSISTOLIK,
					'unit', 'mm[Hg]',
					'system', 'http://unitsofmeasure.org',
					'code', 'mm[Hg]'
				), VCATEGORY, VNOPEN, VCODE, VSUBJECT, VTGL_INPUT, VENCOUNTER, VSEND);
		END IF;
		
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 4) THEN
			SET VCODE = JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(10, 4)
				)
			);
			INSERT INTO `kemkes-ihs`.observation(refId, jenis, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, send)
			   VALUES (VID, 4, 'final', JSON_OBJECT(
					'value', VDISTOLIK,
					'unit', 'mm[Hg]',
					'system', 'http://unitsofmeasure.org',
					'code', 'mm[Hg]'
				), VCATEGORY, VNOPEN, VCODE, VSUBJECT, VTGL_INPUT, VENCOUNTER, VSEND);
		END IF;
		
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.observation r WHERE r.refId = VID AND r.jenis = 5) THEN
			SET VCODE = JSON_OBJECT(
				'coding', JSON_ARRAY(
					`kemkes-ihs`.getObJectReference(10, 5)
				)
			);
			INSERT INTO `kemkes-ihs`.observation(refId, jenis, `status`, valueQuantity, category, nopen, `code`, subject, effectiveDateTime, encounter, send)
			   VALUES (VID, 5, 'final', JSON_OBJECT(
					'value', VSUHU,
					'unit', 'C',
					'system', 'http://unitsofmeasure.org',
					'code', 'Cel'
				), VCATEGORY, VNOPEN, VCODE, VSUBJECT, VTGL_INPUT, VENCOUNTER, VSEND);
		END IF;
		
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 6;
	END LOOP;
	CLOSE CR_TANDAVITAL;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
