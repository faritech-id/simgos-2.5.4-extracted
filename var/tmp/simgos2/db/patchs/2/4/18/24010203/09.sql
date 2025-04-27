-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
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

-- Dumping structure for procedure kemkes-ihs.orderResepToMedication
DROP PROCEDURE IF EXISTS `orderResepToMedication`;
DELIMITER //
CREATE PROCEDURE `orderResepToMedication`()
BEGIN
	DECLARE VNOMOR, VNOPEN CHAR(21);
	DECLARE VBARANG, VSTATUS_RACIKAN, VGROUP_RACIKAN INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_DIAGNOSA CURSOR FOR
	
	SELECT DISTINCT odr.ORDER_ID, odr.FARMASI, odr.RACIKAN, odr.GROUP_RACIKAN, p.NOMOR, op.TANGGAL
		FROM layanan.order_detil_resep odr
		LEFT JOIN `kemkes-ihs`.barang_to_poa_pov pp ON pp.BARANG = odr.FARMASI
		LEFT JOIN layanan.order_resep op ON op.NOMOR = odr.ORDER_ID
		LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = op.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
		LEFT JOIN `kemkes-ihs`.encounter ec ON ec.refId = k.NOPEN
		, `kemkes-ihs`.sinkronisasi s
		WHERE s.ID = 9
		AND r.JENIS_KUNJUNGAN = 1
		AND pp.BARANG IS NOT NULL 
		AND ec.id IS NOT NULL  
		AND op.`STATUS` = 2
		AND op.`STATUS` != 0		
		AND odr.FARMASI != 0		
		AND odr.RACIKAN = 0
		AND op.TANGGAL > s.TANGGAL_TERAKHIR
		AND op.TANGGAL < '2023-09-08 23:59:59'
		AND s.`STATUS` = 1
		ORDER BY op.TANGGAL;
		 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_DIAGNOSA;
	EOF: LOOP
		FETCH CR_DIAGNOSA INTO VNOMOR, VBARANG, VSTATUS_RACIKAN, VGROUP_RACIKAN, VNOPEN, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;		
		BEGIN
			DECLARE VINCREDIENT JSON;
			
			IF VSTATUS_RACIKAN = 1 THEN
				SELECT
					JSON_ARRAYAGG(
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
					)
					INTO
					VINCREDIENT
				FROM layanan.order_detil_resep odr
				LEFT JOIN layanan.order_resep ors ON ors.NOMOR = odr.ORDER_ID
				LEFT JOIN `kemkes-ihs`.barang_to_bza btb ON btb.BARANG = odr.FARMASI
				LEFT JOIN `kemkes-ihs`.bza bza ON bza.id = btb.KODE_BZA
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.`type` = 19 AND btb.SATUAN_DOSIS_KFA = tcr.id
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr2 ON tcr2.`type` = 19 AND btb.SATUAN = tcr2.id
				WHERE odr.ORDER_ID = VNOMOR 
				AND odr.RACIKAN = 1 
				AND odr.GROUP_RACIKAN = VGROUP_RACIKAN				 
				AND tcr.id IS NOT NULL
				AND tcr2.id IS NOT NULL;
				
				/*IF VINCREDIENT IS NOT NULL THEN
					SET VINCREDIENT = JSON_ARRAY(VINCREDIENT);
				END IF; */
				
				SET VBARANG = 0;
			ELSE
				SELECT
					JSON_ARRAYAGG(
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
					)
					INTO
					VINCREDIENT
				FROM layanan.order_detil_resep odr
				LEFT JOIN layanan.order_resep ors ON ors.NOMOR = odr.ORDER_ID
				LEFT JOIN `kemkes-ihs`.barang_to_bza btb ON btb.BARANG = odr.FARMASI
				LEFT JOIN `kemkes-ihs`.bza bza ON bza.id = btb.KODE_BZA
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.`type` = 19 AND btb.SATUAN_DOSIS_KFA = tcr.id
				LEFT JOIN `kemkes-ihs`.type_code_reference tcr2 ON tcr2.`type` = 19 AND btb.SATUAN = tcr2.id
				WHERE odr.ORDER_ID = VNOMOR 
				AND odr.FARMASI = VBARANG 
				AND bza.id IS NOT NULL 
				AND tcr.id IS NOT NULL
				AND tcr2.id IS NOT NULL;
				
				/*IF VINCREDIENT IS NOT NULL THEN
					SET VINCREDIENT = JSON_ARRAY(VINCREDIENT);
				END IF; 
				*/
			END IF;
			
			IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.medication p WHERE p.refId = VNOMOR AND p.barang = VBARANG) THEN
				INSERT INTO `kemkes-ihs`.medication(refId, barang, ingredient, status_racikan, group_racikan, nopen)
				     VALUES (VNOMOR, VBARANG, VINCREDIENT, VSTATUS_RACIKAN, VGROUP_RACIKAN, VNOPEN);
			END IF;
			
			UPDATE `kemkes-ihs`.sinkronisasi
		      SET TANGGAL_TERAKHIR = VTANGGAL
		    WHERE ID = 9;
		    
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
