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
-- Dumping structure for procedure kemkes-ihs.pegawaiToPractitioner
DROP PROCEDURE IF EXISTS `pegawaiToPractitioner`;
DELIMITER //
CREATE PROCEDURE `pegawaiToPractitioner`()
BEGIN
	DECLARE VNIK VARCHAR(30);
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_PASIEN CURSOR FOR
		SELECT DISTINCT kip.NOMOR, p.TANGGAL
		 FROM `master`.pegawai p
		 LEFT JOIN `pegawai`.kartu_identitas kip ON kip.NIP = p.NIP AND kip.JENIS = 1
		 , `kemkes-ihs`.sinkronisasi s
		 WHERE s.ID = 3
		 AND p.TANGGAL > s.TANGGAL_TERAKHIR
		 AND kip.ID IS NOT NULL 
		 ORDER BY p.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_PASIEN;
	EOF: LOOP
		FETCH CR_PASIEN INTO VNIK, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.practitioner p WHERE p.refId = VNIK) THEN
			INSERT INTO `kemkes-ihs`.practitioner(refId)
			     VALUES (VNIK);
		/*ELSE
			UPDATE `kemkes-ihs`.organization			
				STATUS = VSTATUS
			 WHERE refId = VRUANGAN;*/
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 3;
	END LOOP;
	CLOSE CR_PASIEN;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
