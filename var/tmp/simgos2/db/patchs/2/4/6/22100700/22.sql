-- --------------------------------------------------------
-- Host:                         192.168.137.7
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
USE `kemkes-ihs`;
-- Dumping structure for procedure kemkes-ihs.diagnosaToConditition
DROP PROCEDURE IF EXISTS `diagnosaToConditition`;
DELIMITER //
CREATE PROCEDURE `diagnosaToConditition`()
BEGIN
	DECLARE VNOMOR CHAR(10);
	DECLARE VID INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_DIAGNOSA CURSOR FOR
	
		SELECT DISTINCT p.NOMOR, pr.ID, p.TANGGAL
		 FROM medicalrecord.diagnosa pr
		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = pr.NOPEN
		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		 LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
		 , `kemkes-ihs`.sinkronisasi s
		 WHERE s.ID = 5
		 AND r.JENIS_KUNJUNGAN = 1
		 AND p.`STATUS` != 0
		 AND pr.`STATUS` != 0
		 AND pr.INA_GROUPER = 0
		 AND p.TANGGAL > s.TANGGAL_TERAKHIR
		 ORDER BY p.TANGGAL;
		 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_DIAGNOSA;
	EOF: LOOP
		FETCH CR_DIAGNOSA INTO VNOMOR, VID, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.`condition` p WHERE p.refId = VID) THEN
			INSERT INTO `kemkes-ihs`.condition(refId, nopen)
			     VALUES (VID, VNOMOR);
		/*ELSE
			UPDATE `kemkes-ihs`.organization			
				STATUS = VSTATUS
			 WHERE refId = VRUANGAN;*/
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 5;
	END LOOP;
	CLOSE CR_DIAGNOSA;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
