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

-- membuang struktur untuk function master.getHeaderLaporan
DROP FUNCTION IF EXISTS `getHeaderLaporan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getHeaderLaporan`(`PRUANG` CHAR(10)) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE RUANG CHAR(10);
	DECLARE HASIL VARCHAR(250);
   
   SET RUANG = CONCAT(PRUANG,'%');
   
	SELECT CONCAT(
	      'INSTALASI : ',IF(LENGTH(RUANG) < 5,'Semua', i.DESKRIPSI),'\r',
			'UNIT : ',IF(LENGTH(RUANG) < 7,'Semua', u.DESKRIPSI),'\r',
			'SUB UNIT : ',IF(LENGTH(RUANG) < 9,'Semua', r.DESKRIPSI)) INTO HASIL
	FROM master.ruangan r
		  LEFT JOIN master.ruangan u ON r.ID LIKE CONCAT(u.ID,'%') AND u.JENIS=4
		  LEFT JOIN master.ruangan i ON r.ID LIKE CONCAT(i.ID,'%') AND i.JENIS=3
	WHERE r.ID LIKE RUANG AND r.JENIS=5
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
