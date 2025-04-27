-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk layanan
CREATE DATABASE IF NOT EXISTS `layanan`;
USE `layanan`;

-- membuang struktur untuk function layanan.getDeskripsiHasilRad
DROP FUNCTION IF EXISTS `getDeskripsiHasilRad`;
DELIMITER //
CREATE FUNCTION `getDeskripsiHasilRad`(
	`PTINDAKAN_MEDIS` CHAR(11)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VDESKRIPSI TEXT;
	DECLARE VCRLN CHAR(2) DEFAULT '\r\n';
	
	SELECT CONCAT(
			'TS yang terhormat,', VCRLN, VCRLN,
			'Klinis:', VCRLN, h.KLINIS, VCRLN, VCRLN,
			'Hasil:', VCRLN, h.HASIL, VCRLN, VCRLN,
			'Uraian:', VCRLN, h.KESAN, VCRLN, VCRLN,
			'Usul:', VCRLN, h.USUL, VCRLN
	  )
	  INTO VDESKRIPSI
	  FROM layanan.hasil_rad h
	 WHERE h.TINDAKAN_MEDIS = PTINDAKAN_MEDIS;
	
	RETURN IFNULL(VDESKRIPSI, '');
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
