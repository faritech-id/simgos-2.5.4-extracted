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

-- Dumping structure for trigger kemkes-ihs.medication_request_before_update
DROP TRIGGER IF EXISTS `medication_request_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `medication_request_before_update` BEFORE UPDATE ON `medication_request` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VCATEGORI, VSUBJECT, VMEDREFS, VENCOUNT, VREQUESTER, VDSGINTRU, VDISREQUEST JSON;
	DECLARE VSTATUS, VINTENT, VNOPEN, VPRIORITY, VORGID CHAR(50);
	DECLARE VAUNTON VARCHAR(150);
	
	SELECT 
	 JSON_ARRAY(
	 	JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', OLD.refId
		),
		`kemkes-ihs`.getIdentifierUrutanOrderResep(OLD.refId)
	 ),
	 org.id
	 INTO
	 VIDENTIFIER,
	 VORGID
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 26;
	 
	IF OLD.status_racikan = 0 THEN
		SELECT
			k.NOPEN,
			IF(o.CITO = 0, 'routine', 'urgent'),
			`kemkes-ihs`.getPatient(p.NORM),
			`kemkes-ihs`.getEncounter(k.NOPEN),
			`dateFormatUTC`(o.TANGGAL, 1),
			`kemkes-ihs`.`getPractitioner`(dkr.NIP),
			JSON_ARRAY(
				JSON_OBJECT(
					'sequence', 1,
					'text', odr.KETERANGAN,
					'patientInstruction', odr.KETERANGAN,
					'route', JSON_OBJECT(
						'coding', JSON_ARRAY(
							IF(btp.RUTE_OBAT != 0, `kemkes-ihs`.getObJectReference(29, btp.RUTE_OBAT), `kemkes-ihs`.getObJectReference(29, ro.CODE))
						)
					),
					'doseAndRate', JSON_ARRAY(
						JSON_OBJECT(
							'type', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getObJectReference(30, 2)
								)
							)
						)
					)
				)
			),
			JSON_OBJECT(
				'performer', JSON_OBJECT(
					'reference', CONCAT('Organization/',VORGID)
				)
			)
			INTO 
			VNOPEN,
			VPRIORITY,
			VSUBJECT,
			VENCOUNT,
			VAUNTON,
			VREQUESTER,
			VDSGINTRU,
			VDISREQUEST
		 FROM layanan.order_resep o 
		 LEFT JOIN layanan.order_detil_resep odr ON odr.ORDER_ID = o.NOMOR AND odr.FARMASI = OLD.barang
		 LEFT JOIN `kemkes-ihs`.barang_to_poa_pov btp ON btp.BARANG = odr.FARMASI
		 LEFT JOIN `kemkes-ihs`.rute_obat ro ON ro.RUTE = odr.RUTE_PEMBERIAN
		 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = o.KUNJUNGAN
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		 LEFT JOIN `master`.dokter dkr ON dkr.ID = o.DOKTER_DPJP
		 WHERE o.NOMOR = OLD.refId LIMIT 1;
	
	ELSE
		SELECT
			k.NOPEN,
			IF(o.CITO = 0, 'routine', 'urgent'),
			`kemkes-ihs`.getPatient(p.NORM),
			`kemkes-ihs`.getEncounter(k.NOPEN),
			`dateFormatUTC`(o.TANGGAL, 1),
			`kemkes-ihs`.`getPractitioner`(dkr.NIP),
			JSON_ARRAY(
				JSON_OBJECT(
					'sequence', 1,
					'text', odr.KETERANGAN,
					'patientInstruction', odr.KETERANGAN,
					'doseAndRate', JSON_ARRAY(
						JSON_OBJECT(
							'type', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getObJectReference(30, 2)
								)
							)
						)
					)
				)
			),
			JSON_OBJECT(
				'performer', JSON_OBJECT(
					'reference', CONCAT('Organization/',VORGID)
				)
			)
			INTO 
			VNOPEN,
			VPRIORITY,
			VSUBJECT,
			VENCOUNT,
			VAUNTON,
			VREQUESTER,
			VDSGINTRU,
			VDISREQUEST
		 FROM layanan.order_resep o 
		 LEFT JOIN layanan.order_detil_resep odr ON odr.ORDER_ID = o.NOMOR AND odr.GROUP_RACIKAN = OLD.group_racikan
		 LEFT JOIN `kemkes-ihs`.petunjuk_racikan btp ON btp.ID_REFERENSI = odr.PETUNJUK_RACIKAN
		 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = o.KUNJUNGAN
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		 LEFT JOIN `master`.dokter dkr ON dkr.ID = o.DOKTER_DPJP
		 WHERE o.NOMOR = OLD.refId LIMIT 1; 	
	END IF;
	
	SELECT JSON_ARRAY(
		JSON_OBJECT(
			'coding', JSON_ARRAY(
				`kemkes-ihs`.getObJectReference(24, 2)
			)
		)
	)
	INTO 
	VCATEGORI;
	
	SELECT 
		tcr.code
		INTO
		VSTATUS
	 FROM `kemkes-ihs`.type_code_reference tcr
	 WHERE 
	 	tcr.type = 21 AND tcr.id = 4;
	 	
	SELECT 
		tcr.code
		INTO
		VINTENT
	 FROM `kemkes-ihs`.type_code_reference tcr
	 WHERE 
	 	tcr.type = 22 AND tcr.id = 3;
	
	IF OLD.status_racikan = 0 THEN	
		SELECT
			JSON_OBJECT(
				'reference', CONCAT('Medication/', m.id),
				'display', IF(p.KODE_POA IS NOT NULL, pa.display, IF(p.KODE_POV IS NOT NULL, pv.display, b.NAMA))
			)
			INTO
			VMEDREFS
		FROM inventory.barang b
		LEFT JOIN `kemkes-ihs`.medication m ON m.barang = b.ID 
		LEFT JOIN `kemkes-ihs`.barang_to_poa_pov p ON p.BARANG = b.ID
		LEFT JOIN `kemkes-ihs`.pov pv ON pv.id = p.KODE_POV
		LEFT JOIN `kemkes-ihs`.poa pa ON pa.id = p.KODE_POA
		WHERE b.ID = OLD.barang AND m.refId = OLD.refId AND m.jenis = 1;
	ELSE
		SELECT
			JSON_OBJECT(
				'reference', CONCAT('Medication/', m.id)
			)
			INTO
			VMEDREFS
		FROM `kemkes-ihs`.medication m
		WHERE m.group_racikan = OLD.group_racikan AND m.refId = OLD.refId AND m.jenis = 1;
	END IF;
	
	IF VENCOUNT IS NULL OR VMEDREFS IS NULL OR VREQUESTER IS NULL  THEN
		SET NEW.send = 0;
	END IF;
	
	SET NEW.status = VSTATUS;
	SET NEW.intent = VINTENT;
	SET NEW.category = VCATEGORI;
	SET NEW.nopen = VNOPEN;
	SET NEW.priority = VPRIORITY;
	SET NEW.subject = VSUBJECT;
	SET NEW.medicationReference = VMEDREFS;
	SET NEW.encounter = VENCOUNT;
	SET NEW.authoredOn = VAUNTON;
	SET NEW.requester = VREQUESTER;
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.dosageInstruction = VDSGINTRU;
	SET NEW.dispenseRequest = VDISREQUEST;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
