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

-- Dumping structure for procedure kemkes-ihs.tindakanLabToServiceRequest
DROP PROCEDURE IF EXISTS `tindakanLabToServiceRequest`;
DELIMITER //
CREATE PROCEDURE `tindakanLabToServiceRequest`()
BEGIN
	DECLARE VID, VNOMOR CHAR(11);
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_TINDAKAN CURSOR FOR
	
	SELECT DISTINCT tm.ID, k.NOPEN, tm.TANGGAL
	FROM layanan.tindakan_medis tm 
	LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = tm.KUNJUNGAN
	LEFT JOIN `master`.ruangan r ON r.ID = k.RUANGAN
	, `kemkes-ihs`.sinkronisasi s
	WHERE s.ID = 12
	AND t.JENIS = 8 
	AND k.FINAL_HASIL = 1
	AND r.JENIS_KUNJUNGAN = 4
	AND tm.`STATUS` != 0
	AND k.`STATUS` != 0
	AND k.FINAL_HASIL_TANGGAL > s.TANGGAL_TERAKHIR
	AND s.`STATUS` = 1
	ORDER BY tm.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_TINDAKAN;
	EOF: LOOP
		FETCH CR_TINDAKAN INTO VID, VNOMOR, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.service_request p WHERE p.refId = VID) THEN
			INSERT INTO `kemkes-ihs`.service_request(refId, nopen)
			   VALUES (VID, VNOMOR);
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 12;
	END LOOP;
	CLOSE CR_TINDAKAN;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
