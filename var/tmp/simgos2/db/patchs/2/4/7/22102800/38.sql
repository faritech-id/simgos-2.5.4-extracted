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

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk function master.getBulanIndo
DROP FUNCTION IF EXISTS `getBulanIndo`;
DELIMITER //
CREATE FUNCTION `getBulanIndo`(
	`TANGGAL` DATETIME
) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE varhasil VARCHAR(50);
	
	SELECT 
	    CASE MONTH(TANGGAL) 
	      WHEN 1 THEN 'Januari' 
	      WHEN 2 THEN 'Februari' 
	      WHEN 3 THEN 'Maret' 
	      WHEN 4 THEN 'April' 
	      WHEN 5 THEN 'Mei' 
	      WHEN 6 THEN 'Juni' 
	      WHEN 7 THEN 'Juli' 
	      WHEN 8 THEN 'Agustus' 
	      WHEN 9 THEN 'September'
	      WHEN 10 THEN 'Oktober' 
	      WHEN 11 THEN 'November' 
	      WHEN 12 THEN 'Desember' 
	    END INTO varhasil;
	
	RETURN varhasil;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
