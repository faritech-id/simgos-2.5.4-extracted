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

-- membuang struktur untuk function master.getTarifFarmasiPerKelas
DROP FUNCTION IF EXISTS `getTarifFarmasiPerKelas`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getTarifFarmasiPerKelas`(`PKELAS` TINYINT, `PTARIF` DECIMAL(60,2)) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VPERSEN DECIMAL(10,2);
	
	SELECT FARMASI INTO VPERSEN
	  FROM `master`.tarif_farmasi_per_kelas
	 WHERE STATUS = 1
	   AND KELAS = PKELAS
	 LIMIT 1;
	 
	IF FOUND_ROWS() > 0 THEN
		RETURN PTARIF + (PTARIF * (VPERSEN/100));
	END IF;
	
	RETURN PTARIF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
