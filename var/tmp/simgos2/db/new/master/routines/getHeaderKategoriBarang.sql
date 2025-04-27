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

-- membuang struktur untuk function master.getHeaderKategoriBarang
DROP FUNCTION IF EXISTS `getHeaderKategoriBarang`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getHeaderKategoriBarang`(`PKATEGORI` CHAR(10)) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE KATEGORI CHAR(10);
	DECLARE HASIL VARCHAR(250);
   
   SET KATEGORI = CONCAT(PKATEGORI,'%');
   
	SELECT CONCAT(IF(LENGTH(KATEGORI) < 1,'Semua', i.NAMA),' - ',
			IF(LENGTH(KATEGORI) < 3,'Semua', u.NAMA),' - ',
			IF(LENGTH(KATEGORI) < 5,'Semua', k.NAMA)) INTO HASIL
	FROM inventory.kategori k
		  LEFT JOIN inventory.kategori u ON k.ID LIKE CONCAT(u.ID,'%') AND u.JENIS=2
		  LEFT JOIN inventory.kategori i ON k.ID LIKE CONCAT(i.ID,'%') AND i.JENIS=1
	WHERE k.ID LIKE KATEGORI AND k.JENIS=3
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
