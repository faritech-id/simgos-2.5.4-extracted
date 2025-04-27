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

-- membuang struktur untuk function master.getKelompokUmurSurveilans
DROP FUNCTION IF EXISTS `getKelompokUmurSurveilans`;
DELIMITER //
CREATE FUNCTION `getKelompokUmurSurveilans`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS int(11)
    DETERMINISTIC
BEGIN

	
	
	DECLARE idklp, umur, tahun INTEGER;
	
	SET umur= DATEDIFF(PTGLREG,PTGLLAHIR);
	
	SET tahun = umur DIV 365;
	
	SET idklp = IF(umur <=7,1
					, IF(umur >7 AND umur <=28,2
					, IF(umur >28 AND tahun <1,3
					, IF(tahun >=1 AND tahun <=4,4
					, IF(tahun >4 AND tahun <=9,5
					, IF(tahun >10 AND tahun <=14,6
					, IF(tahun >14 AND tahun <=19,7
					, IF(tahun >19 AND tahun <=44,8
					, IF(tahun >44 AND tahun <=54,9
					, IF(tahun >54 AND tahun <=59,10
					, IF(tahun >59 AND tahun <=69,11
					, 12)))))))))));
	
	RETURN idklp;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
