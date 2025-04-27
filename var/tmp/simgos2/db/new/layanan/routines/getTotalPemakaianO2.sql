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

-- membuang struktur untuk function layanan.getTotalPemakaianO2
DROP FUNCTION IF EXISTS `getTotalPemakaianO2`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getTotalPemakaianO2`(`PKUNJUNGAN` CHAR(19)) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VPEMAKAIAN DECIMAL(60,2);
	
	SELECT SUM(o.PEMAKAIAN) INTO VPEMAKAIAN
	  FROM layanan.o2 o
	 WHERE o.KUNJUNGAN = PKUNJUNGAN
	   AND o.`STATUS` = 1
		AND NOT ISNULL(o.PEMAKAIAN);
	
	IF ISNULL(VPEMAKAIAN) THEN
		RETURN 0;
	END IF;
	   
	RETURN VPEMAKAIAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
