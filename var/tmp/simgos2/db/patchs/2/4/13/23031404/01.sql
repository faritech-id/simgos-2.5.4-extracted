-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
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

-- Dumping structure for trigger kemkes-ihs.medication_before_insert
DROP TRIGGER IF EXISTS `medication_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `medication_before_insert` BEFORE INSERT ON `medication` FOR EACH ROW BEGIN
	DECLARE VSRACIK TINYINT(3);
	DECLARE VNOPEN CHAR(10);
	DECLARE VSTATUS CHAR(50);
	DECLARE VSPROVIDER, VIDENTIFIER, VCODE, VFORM, VEXTENSION JSON;
	
	SELECT
		JSON_ARRAY(
			JSON_OBJECT(
				'url', c.system,
				'valueCodeableConcept', 
				JSON_OBJECT(
					'coding', JSON_ARRAY(
						`kemkes-ihs`.getObJectReference(17, IF(NEW.status_racikan = 0, 1, 2))
					)
				)
			)
		)
		INTO 
		VEXTENSION
	 FROM `kemkes-ihs`.code_reference c
	 WHERE c.id = 16;
	
	IF NEW.status_racikan = 0 THEN
		SELECT 
		 JSON_ARRAY(
		 	JSON_OBJECT(
				'system', CONCAT(c.system, '/', org.id),
				'use', 'official',
				'value', CONCAT(NEW.barang)
			)
		 )
		 INTO 
		 VIDENTIFIER
		 FROM `kemkes-ihs`.organization org, `kemkes-ihs`.code_reference c
		WHERE org.refId = 1 
		 AND org.id IS NOT NULL
		 AND c.id = 13;
	END IF;
	
	IF NEW.status_racikan = 0 THEN 
		SELECT
			IF(p.KODE_POA IS NOT NULL OR p.KODE_POV IS NOT NULL, 
				JSON_OBJECT(
					'coding', JSON_ARRAY(
						JSON_OBJECT(
							'system', c.system,
							'code', IF(p.KODE_POA IS NOT NULL, p.KODE_POA, p.KODE_POV),
							'display', IF(p.KODE_POA IS NOT NULL, pa.display, pv.display)
						)
					)
				), JSON_OBJECT(
					'coding', JSON_ARRAY(
						JSON_OBJECT(
							'display', b.NAMA
						)
					)
				)
			),
			IF(p.KODE_POA IS NOT NULL, 
				JSON_OBJECT(
					'coding', JSON_ARRAY(
						`kemkes-ihs`.getObJectReference(15, pa.id_bentuk_sediaan)
					)
				), NULL
			)
			INTO
			VCODE,
			VFORM
		FROM inventory.barang b
		LEFT JOIN `kemkes-ihs`.barang_to_poa_pov p ON p.BARANG = b.ID
		LEFT JOIN `kemkes-ihs`.pov pv ON pv.id = p.KODE_POV
		LEFT JOIN `kemkes-ihs`.poa pa ON pa.id = p.KODE_POA
		, `kemkes-ihs`.code_reference c
		WHERE b.ID = NEW.barang
		AND c.id = 14;
	ELSE
		IF NEW.jenis = 1 THEN
			SELECT 
				IF(pr.ID_CODING IS NOT NULL,
					JSON_OBJECT(
						'coding', JSON_ARRAY(
							`kemkes-ihs`.getObJectReference(15, pr.ID_CODING)
						)
					)
				, NULL) INTO VFORM
			FROM layanan.order_detil_resep odr
			LEFT JOIN `kemkes-ihs`.petunjuk_racikan pr ON pr.ID_REFERENSI = odr.PETUNJUK_RACIKAN
			WHERE odr.ORDER_ID = NEW.refId AND odr.GROUP_RACIKAN = NEW.group_racikan LIMIT 1;
		ELSE
			SELECT 
				IF(pr.ID_CODING IS NOT NULL,
					JSON_OBJECT(
						'coding', JSON_ARRAY(
							`kemkes-ihs`.getObJectReference(15, pr.ID_CODING)
						)
					)
				, NULL) INTO VFORM
			FROM layanan.farmasi far
			LEFT JOIN `kemkes-ihs`.petunjuk_racikan pr ON pr.ID_REFERENSI = far.PETUNJUK_RACIKAN
			WHERE far.KUNJUNGAN = NEW.refId AND far.GROUP_RACIKAN = NEW.group_racikan LIMIT 1;
		END IF;
	END IF;
	
	SELECT 
		tcr.code
		INTO
		VSTATUS
	FROM `kemkes-ihs`.type_code_reference tcr
	WHERE 
		tcr.type = 18 AND tcr.id = 1;
		
	SET NEW.extension = VEXTENSION;
	SET NEW.form = VFORM;
	SET NEW.`status` = VSTATUS;
	SET NEW.code = VCODE;
	SET NEW.identifier = VIDENTIFIER;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
