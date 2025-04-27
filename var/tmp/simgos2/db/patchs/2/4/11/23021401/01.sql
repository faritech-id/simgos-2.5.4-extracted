-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6557
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for master
USE `master`;

-- Dumping structure for function master.getAlamatPasien
DROP FUNCTION IF EXISTS `getAlamatPasien`;
DELIMITER //
CREATE FUNCTION `getAlamatPasien`(
	`PNORM` VARCHAR(8)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT CONCAT(IF(p.ALAMAT='' OR p.ALAMAT IS NULL,''
		, CONCAT(p.ALAMAT,' ')),IF(p.RT='' OR p.RT IS NULL,''
		, CONCAT('RT. ',p.RT,' ')),IF(p.RW='' OR p.RW IS NULL,''
		, CONCAT('RT. ',p.RW,' '))
		, IF(p.WILAYAH='' OR p.WILAYAH IS NULL,''
		, CONCAT('Kel/Desa .',kel.DESKRIPSI,' '
		, 'Kec. ',kec.DESKRIPSI,' '
		, 'Kab/Kota. ',kab.DESKRIPSI,' '
		, 'prov. ',prov.DESKRIPSI)))
		 INTO HASIL
	  FROM master.pasien p
	  LEFT JOIN master.wilayah kel ON kel.ID=p.WILAYAH
	  LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
	  LEFT JOIN master.wilayah kab ON kab.ID = LEFT(p.WILAYAH, 4)
	  LEFT JOIN master.wilayah prov ON prov.ID = LEFT(p.WILAYAH, 2)
	 WHERE p.NORM = PNORM;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;