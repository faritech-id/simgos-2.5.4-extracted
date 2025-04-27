-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
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

-- Dumping structure for trigger kemkes-ihs.medication_dispanse_before_insert
DROP TRIGGER IF EXISTS `medication_dispanse_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `medication_dispanse_before_insert` BEFORE INSERT ON `medication_dispanse` FOR EACH ROW BEGIN
	DECLARE VIDENTIFIER, VCATEGORI, VMEDREFS, VSUBJECT, VCONTEKS, VPERFOMER, VQUANT, VDAYSUPLAY, VDOSINSTR, VLOCATION, VAUTHORIZING JSON;
	DECLARE VORGID, VSTATUS, VNOPEN CHAR(50);
	DECLARE VTGLFINAL VARCHAR(50);
	
	SELECT 
	 JSON_ARRAY(
	 	JSON_OBJECT(
			'system', CONCAT(c.system, '/', org.id),
			'use', 'official',
			'value', NEW.refId
		),
		`kemkes-ihs`.getIdentifierUrutanLayananResep(NEW.refId)
	 ),
	 org.id
	 INTO
	 VIDENTIFIER,
	 VORGID
	 FROM `kemkes-ihs`.organization org
	 , `kemkes-ihs`.code_reference c
	WHERE org.refId = 1 
	 AND org.id IS NOT NULL
	 AND c.id = 31;
	 
	 SELECT 
		tcr.code
		INTO
		VSTATUS
	 FROM `kemkes-ihs`.type_code_reference tcr
	 WHERE 
	 	tcr.type = 33 AND tcr.id = 5;
	 	
	SELECT JSON_OBJECT(
		'coding', JSON_ARRAY(
			`kemkes-ihs`.getObJectReference(34, 2)
		)
	)
	INTO 
	VCATEGORI;
	
	IF NEW.status_racikan = 0 THEN	
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
		WHERE b.ID = NEW.barang AND m.refId = NEW.refId AND m.jenis = 2;
	ELSE
		SELECT
			JSON_OBJECT(
				'reference', CONCAT('Medication/', m.id)
			)
			INTO
			VMEDREFS
		FROM `kemkes-ihs`.medication m
		WHERE m.group_racikan = NEW.group_racikan AND m.refId = NEW.refId AND m.jenis = 2;
	END IF;
	
	IF NEW.status_racikan = 0 THEN
		SELECT
			k.NOPEN,
			`kemkes-ihs`.getPatient(p.NORM),
			`kemkes-ihs`.getEncounter(p.NOMOR),
			IF( `kemkes-ihs`.getPractitioner(usr.NIP) IS NOT NULL,
				JSON_ARRAY(
					JSON_OBJECT(
						'actor', `kemkes-ihs`.getPractitioner(usr.NIP)
					)
				)
			, NULL),
			IF(bza.ID IS NOT NULL,
				JSON_OBJECT(
					'value', o.JUMLAH,
					'code', tcr.code,
					'system', tcr.system
				)
			, NULL),
			JSON_OBJECT(
				'value', IFNULL(o.HARI, far.SIGNA2),
				'unit', 'Day',
				'system', 'http://unitsofmeasure.org',
				'code', 'd'
			),
			`dateFormatUTC`(k.KELUAR, 1),
			JSON_ARRAY(
				JSON_OBJECT(
					'sequence', 1,
					'text', o.KETERANGAN,
					'timing', JSON_OBJECT(
						'repeat', JSON_OBJECT(
							'frequency', IFNULL(o.SIGNA1, far.SIGNA1),
							'period', IFNULL(o.SIGNA2, far.SIGNA2),
							'periodUnit', 'd'
						)
					),
					'doseAndRate', JSON_ARRAY(
						JSON_OBJECT(
							'type', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getObJectReference(30, 2)
								)
							),
							'doseQuantity', JSON_OBJECT(
								'value', IFNULL(o.SIGNA1, far.SIGNA1),
								'code', tcr.code,
								'system', tcr.system
							)
						)
					)
				)
			),
			IF(loc.id IS NOT NULL, 
				JSON_OBJECT(
					'reference', CONCAT('Location/', loc.id),
					'display', loc.`name`
				)
			, NULL)
			, IF(mreq.id IS NOT NULL,
				JSON_ARRAY(
					JSON_OBJECT(
						'reference', CONCAT('MedicationRequest/', mreq.id)
					)
				)
			, NULL)
			INTO 
			VNOPEN,
			VSUBJECT,
			VCONTEKS,
			VPERFOMER,
			VQUANT,
			VDAYSUPLAY,
			VTGLFINAL,
			VDOSINSTR,
			VLOCATION,
			VAUTHORIZING
		 FROM layanan.farmasi o 
		 LEFT JOIN layanan.order_detil_resep odr ON odr.REF = o.ID	
		 LEFT JOIN `kemkes-ihs`.medication_request mreq ON mreq.refId = odr.ORDER_ID AND odr.FARMASI = odr.FARMASI AND mreq.group_racikan = odr.GROUP_RACIKAN	
		 LEFT JOIN `kemkes-ihs`.petunjuk_racikan btp ON btp.ID_REFERENSI = o.PETUNJUK_RACIKAN
		 LEFT JOIN `kemkes-ihs`.barang_to_bza bza ON bza.BARANG = o.FARMASI
		 LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.type = 19 AND bza.SATUAN = tcr.id
		 LEFT JOIN aplikasi.pengguna usr ON usr.ID = o.OLEH
		 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = o.KUNJUNGAN
		 LEFT JOIN `kemkes-ihs`.location loc ON loc.refId = k.RUANGAN
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		 LEFT JOIN `master`.frekuensi_aturan_resep far ON far.ID = o.FREKUENSI
		 WHERE o.KUNJUNGAN = NEW.refId AND o.FARMASI = NEW.barang LIMIT 1;
	ELSE
		SELECT
			k.NOPEN,
			`kemkes-ihs`.getPatient(p.NORM),
			`kemkes-ihs`.getEncounter(p.NOMOR),
			IF(`kemkes-ihs`.getPractitioner(usr.NIP) IS NOT NULL,
				JSON_ARRAY(
					JSON_OBJECT(
						'actor', `kemkes-ihs`.getPractitioner(usr.NIP)
					)
				)
			, NULL),
			IF(tcr.id IS NOT NULL,
				JSON_OBJECT(
					'value', (o.SIGNA1 * o.SIGNA2 * o.HARI),
					'code', tcr.code,
					'system', tcr.system
				)
			, NULL),
			JSON_OBJECT(
				'value', IFNULL(o.HARI, far.SIGNA2),
				'unit', 'Day',
				'system', 'http://unitsofmeasure.org',
				'code', 'd'
			),
			`dateFormatUTC`(k.KELUAR, 1),
			JSON_ARRAY(
				JSON_OBJECT(
					'sequence', 1,
					'text', o.KETERANGAN,
					'timing', JSON_OBJECT(
						'repeat', JSON_OBJECT(
							'frequency', IFNULL(o.SIGNA1, far.SIGNA1),
							'period', IFNULL(o.SIGNA2, far.SIGNA2),
							'periodUnit', 'd'
						)
					),
					'doseAndRate', JSON_ARRAY(
						JSON_OBJECT(
							'type', JSON_OBJECT(
								'coding', JSON_ARRAY(
									`kemkes-ihs`.getObJectReference(30, 2)
								)
							),
							'doseQuantity', JSON_OBJECT(
								'value', IFNULL(o.SIGNA1, far.SIGNA1),
								'code', tcr.code,
								'system', tcr.system
							)
						)
					)
				)
			),
			IF(loc.id IS NOT NULL, 
				JSON_OBJECT(
					'reference', CONCAT('Location/', loc.id),
					'display', loc.`name`
				)
			, NULL)
			, IF(mreq.id IS NOT NULL,
				JSON_ARRAY(
					JSON_OBJECT(
						'reference', CONCAT('MedicationRequest/', mreq.id)
					)
				)
			, NULL)
			INTO 
			VNOPEN,
			VSUBJECT,
			VCONTEKS,
			VPERFOMER,
			VQUANT,
			VDAYSUPLAY,
			VTGLFINAL,
			VDOSINSTR,
			VLOCATION, 
			VAUTHORIZING
		 FROM layanan.farmasi o 
		 LEFT JOIN layanan.order_detil_resep odr ON odr.REF = o.ID	
		 LEFT JOIN `kemkes-ihs`.medication_request mreq ON mreq.refId = odr.ORDER_ID AND odr.FARMASI = odr.FARMASI AND mreq.group_racikan = odr.GROUP_RACIKAN	
		 LEFT JOIN `kemkes-ihs`.petunjuk_racikan btp ON btp.ID_REFERENSI = o.PETUNJUK_RACIKAN
		 LEFT JOIN `kemkes-ihs`.type_code_reference tcr ON tcr.type = 19 AND btp.SATUAN = tcr.id
		 LEFT JOIN aplikasi.pengguna usr ON usr.ID = o.OLEH
		 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = o.KUNJUNGAN
		 LEFT JOIN `kemkes-ihs`.location loc ON loc.refId = k.RUANGAN
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		 LEFT JOIN `master`.frekuensi_aturan_resep far ON far.ID = o.FREKUENSI
		 WHERE o.KUNJUNGAN = NEW.refId AND o.GROUP_RACIKAN = NEW.group_racikan LIMIT 1; 	
	END IF;
	
	IF VCONTEKS IS NULL OR VPERFOMER IS NULL OR VMEDREFS IS NULL THEN
		SET NEW.send = 0;
	END IF;
	
	SET NEW.identifier = VIDENTIFIER;
	SET NEW.category = VCATEGORI;
	SET NEW.medicationReference = VMEDREFS;
	SET NEW.status = VSTATUS;
	SET NEW.nopen = VNOPEN;
	SET NEW.subject = VSUBJECT;
	SET NEW.context = VCONTEKS;
	SET NEW.performer = VPERFOMER;
	SET NEW.quantity = VQUANT;
	SET NEW.daysSupply = VDAYSUPLAY;
	SET NEW.whenPrepared = VTGLFINAL;
	SET NEW.whenHandedOver = VTGLFINAL;
	SET NEW.dosageInstruction = VDOSINSTR;
	SET NEW.location = VLOCATION;
	SET NEW.authorizingPrescription = VAUTHORIZING;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
