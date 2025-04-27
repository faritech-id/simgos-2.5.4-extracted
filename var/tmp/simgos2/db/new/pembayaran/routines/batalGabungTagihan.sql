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

-- membuang struktur untuk procedure pembayaran.batalGabungTagihan
DROP PROCEDURE IF EXISTS `batalGabungTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `batalGabungTagihan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_BATAL_GABUNG;

	CREATE TEMPORARY TABLE TEMP_BATAL_GABUNG ENGINE = MEMORY
	SELECT * 
	  FROM pembayaran.tagihan_pendaftaran tp
	 WHERE tp.TAGIHAN = PTAGIHAN
	   AND tp.UTAMA = 0
	   AND tp.`STATUS` = 1;
	   	
	UPDATE pembayaran.tagihan_pendaftaran tp
	   SET tp.STATUS = 0
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND tp.STATUS = 1
		   AND tp.UTAMA = 0;
		   
	UPDATE pembayaran.tagihan t, pembayaran.tagihan_pendaftaran tp, TEMP_BATAL_GABUNG bg
	   SET t.STATUS = 1
	 WHERE t.ID = tp.TAGIHAN AND t.STATUS = 0
	   AND NOT tp.TAGIHAN = bg.TAGIHAN 	
	   AND tp.STATUS = 0
	   AND tp.UTAMA = 1
		AND tp.PENDAFTARAN = bg.PENDAFTARAN;
		   
	UPDATE pembayaran.tagihan_pendaftaran tp, TEMP_BATAL_GABUNG bg
	   SET tp.STATUS = 1
	 WHERE NOT tp.TAGIHAN = bg.TAGIHAN 	
	   AND tp.STATUS = 0
	   AND tp.UTAMA = 1
		AND tp.PENDAFTARAN = bg.PENDAFTARAN;
		
	DELETE FROM pembayaran.tagihan_pendaftaran WHERE TAGIHAN = PTAGIHAN AND STATUS = 0 AND UTAMA = 0;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
