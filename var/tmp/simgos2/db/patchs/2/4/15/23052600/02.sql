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

-- Dumping structure for procedure kemkes-ihs.pendaftaranToConsent
DROP PROCEDURE IF EXISTS `pendaftaranToConsent`;
DELIMITER //
CREATE PROCEDURE `pendaftaranToConsent`()
BEGIN
	DECLARE VNOMOR CHAR(10);
	DECLARE VNORM, VSTATUS_CONSENT INT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VUSER VARCHAR(75);
	DECLARE VID_PASIEN_IHS CHAR(36);
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_PENDAFTARAN CURSOR FOR
	
	SELECT DISTINCT p.NOMOR, p.NORM, peng.NAMA, pt.id, p.CONSENT_SATUSEHAT, p.TANGGAL
		FROM pendaftaran.pendaftaran p
		LEFT JOIN aplikasi.pengguna peng ON peng.ID = p.OLEH
		LEFT JOIN `kemkes-ihs`.patient pt ON pt.refId = p.NORM
		, `kemkes-ihs`.sinkronisasi s
		WHERE s.ID = 13
		AND p.`STATUS` != 0
		AND p.TANGGAL > s.TANGGAL_TERAKHIR
		ORDER BY p.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_PENDAFTARAN;
	EOF: LOOP
		FETCH CR_PENDAFTARAN INTO VNOMOR, VNORM, VUSER, VID_PASIEN_IHS, VSTATUS_CONSENT, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF VID_PASIEN_IHS IS NOT NULL THEN
			IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.consent p WHERE p.refId = VNOMOR) THEN
				INSERT INTO `kemkes-ihs`.consent(refId, norm, bodySend, send)
				   VALUES (VNOMOR, VNORM, JSON_OBJECT(
						'patient_id', VID_PASIEN_IHS,
						'agent', VUSER,
						'action', IF(VSTATUS_CONSENT = 1, 'OPTIN', 'OPTOUT')
					), 1);
			END IF;
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 13;
	END LOOP;
	CLOSE CR_PENDAFTARAN;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
