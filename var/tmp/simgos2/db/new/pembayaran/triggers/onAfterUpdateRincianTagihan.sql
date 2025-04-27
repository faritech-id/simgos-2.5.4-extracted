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

-- membuang struktur untuk trigger pembayaran.onAfterUpdateRincianTagihan
DROP TRIGGER IF EXISTS `onAfterUpdateRincianTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `onAfterUpdateRincianTagihan` AFTER UPDATE ON `rincian_tagihan` FOR EACH ROW BEGIN
	IF (NEW.JUMLAH != OLD.JUMLAH OR NEW.TARIF != OLD.TARIF) AND OLD.STATUS = 1 THEN
		UPDATE pembayaran.tagihan
		   SET TOTAL = TOTAL - (OLD.JUMLAH * OLD.TARIF)
		 WHERE ID = OLD.TAGIHAN;
		 
		UPDATE pembayaran.tagihan
		   SET TOTAL = TOTAL + (NEW.JUMLAH * NEW.TARIF)
		 WHERE ID = OLD.TAGIHAN;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
