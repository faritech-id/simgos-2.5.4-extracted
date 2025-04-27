-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk function pendaftaran.ikutRawatInapIbu
DROP FUNCTION IF EXISTS `ikutRawatInapIbu`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `ikutRawatInapIbu`(
	`PNOPEN` CHAR(10),
	`PREF_KUNJUNGAN` CHAR(21)
) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	IF(PREF_KUNJUNGAN IS NULL) THEN
		RETURN EXISTS(SELECT 1
		  FROM pendaftaran.tujuan_pasien tp
		 WHERE tp.NOPEN = PNOPEN	
		   AND tp.IKUT_IBU = 1 
			AND tp.`STATUS` > 0
		 LIMIT 1);
	ELSE
		RETURN EXISTS(SELECT 1
		  FROM pendaftaran.mutasi m
		 WHERE m.NOMOR = PREF_KUNJUNGAN
		   AND m.IKUT_IBU = 1
			AND m.`STATUS` > 0
		 LIMIT 1);
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
