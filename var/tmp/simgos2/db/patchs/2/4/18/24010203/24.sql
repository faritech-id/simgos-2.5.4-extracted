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

-- Dumping structure for function kemkes-ihs.getPeriode
DROP FUNCTION IF EXISTS `getPeriode`;
DELIMITER //
CREATE FUNCTION `getPeriode`(
	`PNOMOR` CHAR(10)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VPERIODE JSON;
	DECLARE VFOUND, VSTATUS TINYINT;
	
	SELECT 
	 COUNT(*),
	 IF(p.TANGGAL IS NULL, NULL, JSON_OBJECT(
		'start', `dateFormatUTC`(p.TANGGAL, 1),
		'end', `dateFormatUTC`(k.KELUAR, 1)
	 )),
	 p.`STATUS`
	 INTO
	 VFOUND,
	 VPERIODE,
	 VSTATUS
	 FROM pendaftaran.pendaftaran p
	LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	LEFT JOIN pendaftaran.kunjungan k ON k.RUANGAN = tp.RUANGAN AND k.NOPEN = tp.NOPEN 
	WHERE p.NOMOR = PNOMOR AND k.REF IS NULL;
	
	IF VFOUND > 0 THEN	
		IF VSTATUS != 2  THEN
			SET VPERIODE = JSON_REMOVE(VPERIODE, '$[2]', '$[1]', '$.end');
		END IF;
	END IF;
	
	
 	RETURN VPERIODE;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
