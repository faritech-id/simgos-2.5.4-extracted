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

-- membuang struktur untuk procedure pembayaran.finalkanKunjunganBlmFinal
DROP PROCEDURE IF EXISTS `finalkanKunjunganBlmFinal`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `finalkanKunjunganBlmFinal`(
	IN `PTAGIHAN` CHAR(10)


)
BEGIN
	UPDATE pembayaran.tagihan t,
	  		 pembayaran.tagihan_pendaftaran tp,
	  		 pendaftaran.kunjungan k
	   SET k.`STATUS` = 2
	 WHERE t.ID = PTAGIHAN
	 	AND t.`STATUS` = 1
	   AND tp.TAGIHAN = t.ID
	   AND k.NOPEN = tp.PENDAFTARAN
	   AND k.`STATUS` = 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
