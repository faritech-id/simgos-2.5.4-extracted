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

-- membuang struktur untuk function master.getKelompokUmur
DROP FUNCTION IF EXISTS `getKelompokUmur`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getKelompokUmur`(`PTGLREG` DATETIME, `PTGLLAHIR` DATETIME) RETURNS int(11)
    DETERMINISTIC
BEGIN

	
	
	DECLARE idklp, umur, tahun INTEGER;
	
	SET umur= DATEDIFF(PTGLREG,PTGLLAHIR);
	
	SET tahun = umur DIV 365;
	
	SET idklp = IF(umur <=6,1
					, IF(umur >6 AND umur <=28,2
					, IF(umur >28 AND tahun <=1,3
					, IF(tahun >1 AND tahun <=4,4
					, IF(tahun >4 AND tahun <=14,5
					, IF(tahun >14 AND tahun <=24,6
					, IF(tahun >24 AND tahun <=44,7
					, IF(tahun >44 AND tahun <=64,8
					, 9))))))));
	
	RETURN idklp;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
