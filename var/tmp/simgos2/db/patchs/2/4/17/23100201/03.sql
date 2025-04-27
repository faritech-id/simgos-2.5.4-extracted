-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk function master.getKelompokUmurKemkes
DROP FUNCTION IF EXISTS `getKelompokUmurKemkes`;
DELIMITER //
CREATE FUNCTION `getKelompokUmurKemkes`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS int(11)
    DETERMINISTIC
BEGIN

	
	
	DECLARE idklp, umur, tahun INTEGER;
	
	SET umur= DATEDIFF(PTGLREG,PTGLLAHIR);
	
	SET tahun = umur DIV 365;
	
	SET idklp = IF(tahun <=5,1
					, IF(tahun >5 AND tahun <=11,2
					, IF(tahun >11 AND tahun <=16,3
					, IF(tahun >16 AND tahun <=25,4
					, IF(tahun >25 AND tahun <=35,5
					, IF(tahun >35 AND tahun <=45,6
					, IF(tahun >45 AND tahun <=55,7
					, IF(tahun >55 AND tahun <=65,8
					, 9))))))));
	
	RETURN idklp;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
