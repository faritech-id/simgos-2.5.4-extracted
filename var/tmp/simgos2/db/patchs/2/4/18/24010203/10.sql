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

-- Dumping structure for procedure kemkes-ihs.pasienToPatient
DROP PROCEDURE IF EXISTS `pasienToPatient`;
DELIMITER //
CREATE PROCEDURE `pasienToPatient`()
BEGIN
	DECLARE VNIK VARCHAR(30);
	DECLARE VNORM INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_PASIEN CURSOR FOR
		SELECT DISTINCT kip.NOMOR, p.NORM, p.TANGGAL
		 FROM `master`.pasien p
		 LEFT JOIN `master`.kartu_identitas_pasien kip ON kip.NORM = p.NORM AND kip.JENIS = 1
		 , `kemkes-ihs`.sinkronisasi s
		 WHERE s.ID = 2
		 AND p.TANGGAL > s.TANGGAL_TERAKHIR
		 AND kip.NORM IS NOT NULL 
		 AND s.`STATUS` = 1
		 ORDER BY p.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_PASIEN;
	EOF: LOOP
		FETCH CR_PASIEN INTO VNIK, VNORM, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.patient p WHERE p.refId = VNORM) THEN
			IF VNIK != '' THEN
				INSERT INTO `kemkes-ihs`.patient(refId, nik)
				     VALUES (VNORM, VNIK);
			END IF;
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 2;
	END LOOP;
	CLOSE CR_PASIEN;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
