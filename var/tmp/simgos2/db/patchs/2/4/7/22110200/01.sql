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
		'start', DATE_FORMAT(p.TANGGAL,'%Y-%m-%dT%TZ'),
		'end', DATE_FORMAT(k.KELUAR,'%Y-%m-%dT%TZ')
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
		IF VSTATUS = 1 THEN
			SET VPERIODE = JSON_REMOVE(VPERIODE, '$[2]', '$[1]', '$.end');
		END IF;
	END IF;
	
	
 	RETURN VPERIODE;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
