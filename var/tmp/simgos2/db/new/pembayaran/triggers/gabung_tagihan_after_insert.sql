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

-- membuang struktur untuk trigger pembayaran.gabung_tagihan_after_insert
DROP TRIGGER IF EXISTS `gabung_tagihan_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `gabung_tagihan_after_insert` AFTER INSERT ON `gabung_tagihan` FOR EACH ROW BEGIN
	UPDATE pembayaran.tagihan
	   SET STATUS = 0
	 WHERE ID = NEW.DARI;
			  
	UPDATE pembayaran.tagihan_pendaftaran
	   SET STATUS = 0
	 WHERE TAGIHAN = NEW.DARI
	   AND STATUS = 1;
	   
	INSERT INTO pembayaran.tagihan_pendaftaran(TAGIHAN, PENDAFTARAN, UTAMA)
		  SELECT NEW.KE, PENDAFTARAN, 0
		    FROM pembayaran.tagihan_pendaftaran
		   WHERE TAGIHAN = NEW.DARI;			
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
