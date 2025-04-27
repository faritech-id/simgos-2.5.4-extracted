-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
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

-- membuang struktur untuk function master.getWilayah
DELIMITER //
CREATE FUNCTION `getWilayah`(
	`PWILAYAH` CHAR(10),
	`PJENISWILAYAH` TINYINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   DECLARE VWILAYAH CHAR(10);

   SET VWILAYAH = LEFT(PWILAYAH, IF(PJENISWILAYAH = 1, 2, IF(PJENISWILAYAH = 2, 4, IF(PJENISWILAYAH = 3, 6, IF(PJENISWILAYAH = 4, 10, 0)))));

   #PJENISWILAYAH 1=Propinsi, 2=Kab/Kota, 3=Kecamatan, 4=Kelurahan
   SELECT w.DESKRIPSI INTO HASIL 
	 FROM `master`.wilayah w 
 	 WHERE w.JENIS = PJENISWILAYAH 
       AND w.ID = VWILAYAH;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
