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

-- Dumping structure for procedure kemkes-ihs.procedureToProcedure
DROP PROCEDURE IF EXISTS `procedureToProcedure`;
DELIMITER //
CREATE PROCEDURE `procedureToProcedure`()
BEGIN
	DECLARE VNOMOR CHAR(10);
	DECLARE VTANGGAL DATETIME;
	DECLARE VID INT;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_PENDAFTARAN CURSOR FOR
	
	SELECT DISTINCT p.NOPEN, p.ID, p.TANGGAL
		FROM medicalrecord.prosedur p
		 LEFT JOIN pendaftaran.pendaftaran pn ON pn.NOMOR = p.NOPEN
	  	 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pn.NOMOR
		 LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
		, `kemkes-ihs`.sinkronisasi s
		WHERE s.ID = 7
		AND p.KODE != ''
		AND p.`STATUS` != 0
		AND p.TANGGAL > s.TANGGAL_TERAKHIR
		AND r.JENIS_KUNJUNGAN = 1
		AND s.`STATUS` = 1
		GROUP BY p.NOPEN, p.KODE ORDER BY p.TANGGAL;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_PENDAFTARAN;
	EOF: LOOP
		FETCH CR_PENDAFTARAN INTO VNOMOR, VID, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.`procedure` p WHERE p.refId = VID) THEN
			INSERT INTO `kemkes-ihs`.procedure(refId, nopen)
			   VALUES (VID, VNOMOR);
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID =7;
	END LOOP;
	CLOSE CR_PENDAFTARAN;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
