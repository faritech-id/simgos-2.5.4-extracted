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

-- Dumping structure for procedure kemkes-ihs.riwayatAlergiToAllergyIntolerance
DROP PROCEDURE IF EXISTS `riwayatAlergiToAllergyIntolerance`;
DELIMITER //
CREATE PROCEDURE `riwayatAlergiToAllergyIntolerance`()
BEGIN
	DECLARE VNOMOR CHAR(10);
	DECLARE VID INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_DIAGNOSA CURSOR FOR
	
	SELECT DISTINCT p.NOMOR, ra.ID, ra.TANGGAL
	 FROM medicalrecord.riwayat_alergi ra
	 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = ra.KUNJUNGAN
	 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	 LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
	 , `kemkes-ihs`.sinkronisasi s
	 WHERE s.ID = 16
	 AND r.JENIS_KUNJUNGAN = 1
	 AND p.`STATUS` != 0
	 AND ra.`STATUS` != 0
	 AND ra.TANGGAL > s.TANGGAL_TERAKHIR
	 AND s.`STATUS` = 1
	 ORDER BY ra.TANGGAL;
		 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_DIAGNOSA;
	EOF: LOOP
		FETCH CR_DIAGNOSA INTO VNOMOR, VID, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.allergy_intolerance com WHERE com.refId = VID LIMIT 1) THEN
			INSERT INTO `kemkes-ihs`.allergy_intolerance(refId, nopen)
			     VALUES (VID, VNOMOR);
		ELSE 
			UPDATE allergy_intolerance SET send = 1
			WHERE refId = VID;
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 16;
	END LOOP;
	CLOSE CR_DIAGNOSA;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
