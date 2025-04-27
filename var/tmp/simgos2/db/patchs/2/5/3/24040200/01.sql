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

-- Dumping structure for procedure kemkes-ihs.pelayanaResepToMedication
DROP PROCEDURE IF EXISTS `pelayanaResepToMedication`;
DELIMITER //
CREATE PROCEDURE `pelayanaResepToMedication`()
BEGIN
	DECLARE VNOMOR, VKUNJUNGAN, VNOPEN CHAR(21);
	DECLARE VBARANG, VSTATUS_RACIKAN, VGROUP_RACIKAN INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_DIAGNOSA CURSOR FOR
	
	SELECT DISTINCT far.ID, far.KUNJUNGAN, far.FARMASI, far.RACIKAN, far.GROUP_RACIKAN, p.NOMOR, far.TANGGAL
		FROM layanan.farmasi far
		LEFT JOIN `kemkes-ihs`.barang_to_poa_pov pp ON pp.BARANG = far.FARMASI
		LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = far.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN		
		LEFT JOIN `kemkes-ihs`.encounter ec ON ec.refId = k.NOPEN
		, `kemkes-ihs`.sinkronisasi s
		WHERE s.ID = 10
		AND pp.BARANG IS NOT NULL 
		AND ec.id IS NOT NULL 
		AND r.JENIS_KUNJUNGAN = 1
		AND far.`STATUS` = 2
		AND far.`STATUS` != 0
		AND far.TANGGAL > s.TANGGAL_TERAKHIR
		AND s.`STATUS` = 1
		ORDER BY far.TANGGAL;
		 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_DIAGNOSA;
	EOF: LOOP
		FETCH CR_DIAGNOSA INTO VNOMOR, VKUNJUNGAN, VBARANG, VSTATUS_RACIKAN, VGROUP_RACIKAN, VNOPEN, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;		
		BEGIN
			DECLARE VINCREDIENT JSON;
			
			IF VSTATUS_RACIKAN = 1 THEN
				SELECT
					GROUP_CONCAT(IF(bza.id IS NOT NULL,
						JSON_OBJECT(
							'itemCodeableConcept', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getBza(btb.KODE_BZA)
								)
							),
							'isActive', true,
							'strength', JSON_OBJECT(
								'numerator', JSON_OBJECT(
									'value',  btb.DOSIS_KFA,
									'system', tcr.system,
									'code', tcr.`code`
								),
								'denominator', JSON_OBJECT(
									'value',  ROUND(btb.DOSIS_PERSATUAN, 2),
									'system', tcr2.system,
									'code', tcr2.`code`
								)
							)
						)
					, NULL))
					INTO
					VINCREDIENT
				FROM layanan.farmasi far
				LEFT JOIN `kemkes-ihs`.barang_to_bza btb ON btb.BARANG = far.FARMASI
				LEFT JOIN `kemkes-ihs`.bza bza ON bza.id = btb.KODE_BZA
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.`type` = 19 AND btb.SATUAN_DOSIS_KFA = tcr.id
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr2 ON tcr2.`type` = 19 AND btb.SATUAN = tcr2.id
				WHERE far.KUNJUNGAN = VKUNJUNGAN AND far.`STATUS` = 2 AND far.RACIKAN = 1 AND far.GROUP_RACIKAN = VGROUP_RACIKAN;
				
				SET VBARANG = 0;
			ELSE
				SELECT
					JSON_ARRAYAGG(JSON_OBJECT(
							'itemCodeableConcept', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getBza(btb.KODE_BZA)
								)
							),
							'isActive', true,
							'strength', JSON_OBJECT(
								'numerator', JSON_OBJECT(
									'value',  btb.DOSIS_KFA,
									'system', tcr.system,
									'code', tcr.`code`
								),
								'denominator', JSON_OBJECT(
									'value',  ROUND(btb.DOSIS_PERSATUAN, 2),
									'system', tcr2.system,
									'code', tcr2.`code`
								)
							)
						))
					INTO
					VINCREDIENT
				FROM layanan.farmasi far
				LEFT JOIN `kemkes-ihs`.barang_to_bza btb ON btb.BARANG = far.FARMASI
				LEFT JOIN `kemkes-ihs`.bza bza ON bza.id = btb.KODE_BZA
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.`type` = 19 AND btb.SATUAN_DOSIS_KFA = tcr.id
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr2 ON tcr2.`type` = 19 AND btb.SATUAN = tcr2.id
				WHERE far.KUNJUNGAN = VKUNJUNGAN AND far.`STATUS` = 2 AND far.FARMASI = VBARANG AND bza.id IS NOT NULL;
				
			END IF;
			
			IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.medication p WHERE p.refId = VKUNJUNGAN AND p.jenis = 2) THEN
				INSERT INTO `kemkes-ihs`.medication(refId, barang, ingredient, status_racikan, group_racikan, nopen, jenis)
				     VALUES (VKUNJUNGAN, VBARANG, VINCREDIENT, VSTATUS_RACIKAN, VGROUP_RACIKAN, VNOPEN, 2);
			END IF;	
			
			UPDATE `kemkes-ihs`.sinkronisasi
		      SET TANGGAL_TERAKHIR = VTANGGAL
		    WHERE ID = 10;
		    
	   END;
	END LOOP;
	CLOSE CR_DIAGNOSA;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
