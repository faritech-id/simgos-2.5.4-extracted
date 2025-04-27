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

-- Dumping structure for procedure kemkes-ihs.edukasiToComposition
DROP PROCEDURE IF EXISTS `edukasiToComposition`;
DELIMITER //
CREATE PROCEDURE `edukasiToComposition`()
BEGIN
	DECLARE VNOMOR CHAR(10);
	DECLARE VID INT;
	DECLARE VTANGGAL DATETIME;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE CR_DIAGNOSA CURSOR FOR
	
	SELECT DISTINCT p.NOMOR, epk.ID, p.TANGGAL
	 FROM medicalrecord.edukasi_pasien_keluarga epk
	 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = epk.KUNJUNGAN
	 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	 LEFT JOIN `master`.ruangan r ON r.ID = tp.RUANGAN
	 , `kemkes-ihs`.sinkronisasi s
	 WHERE s.ID = 11
	 AND epk.EDUKASI_NUTRISI = 1
	 AND r.JENIS_KUNJUNGAN = 1
	 AND p.`STATUS` != 0
	 AND epk.`STATUS` != 0
	 AND epk.TANGGAL > s.TANGGAL_TERAKHIR
	 ORDER BY p.TANGGAL;
		 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN CR_DIAGNOSA;
	EOF: LOOP
		FETCH CR_DIAGNOSA INTO VNOMOR, VID, VTANGGAL;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM `kemkes-ihs`.composition com WHERE com.refId = VID AND com.nopen = VNOMOR LIMIT 1) THEN
			INSERT INTO `kemkes-ihs`.composition(refId, nopen)
			     VALUES (VID, VNOMOR);
		
		END IF;
		
		UPDATE `kemkes-ihs`.sinkronisasi
	      SET TANGGAL_TERAKHIR = VTANGGAL
	    WHERE ID = 11;
	END LOOP;
	CLOSE CR_DIAGNOSA;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
