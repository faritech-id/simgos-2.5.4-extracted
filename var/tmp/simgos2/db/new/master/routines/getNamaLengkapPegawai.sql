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

-- membuang struktur untuk function master.getNamaLengkapPegawai
DROP FUNCTION IF EXISTS `getNamaLengkapPegawai`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getNamaLengkapPegawai`(`PNIP` VARCHAR(30)) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT CONCAT(IF(GELAR_DEPAN='' OR GELAR_DEPAN IS NULL,'',CONCAT(GELAR_DEPAN,'. ')),UPPER(NAMA),IF(GELAR_BELAKANG='' OR GELAR_BELAKANG IS NULL,'',CONCAT(', ',GELAR_BELAKANG))) INTO HASIL
	  FROM master.pegawai
	 WHERE NIP = PNIP;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
