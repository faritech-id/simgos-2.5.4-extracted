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

-- membuang struktur untuk trigger pembayaran.onAfterUpdateTagihan
DROP TRIGGER IF EXISTS `onAfterUpdateTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTagihan` AFTER UPDATE ON `tagihan` FOR EACH ROW BEGIN
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
		IF OLD.JENIS = 1 THEN
			
			
			
			UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
			   SET p.STATUS = 2
			 WHERE tp.PENDAFTARAN = p.NOMOR
			   AND tp.`STATUS` = 1
				AND tp.TAGIHAN = OLD.ID;
				
			UPDATE pembayaran.pembatalan_tagihan
			   SET STATUS = 2
			 WHERE TAGIHAN = OLD.ID
			   AND STATUS = 1;
		ELSEIF OLD.JENIS = 4 THEN
			UPDATE penjualan.penjualan
			   SET STATUS = 2
			 WHERE NOMOR = OLD.ID;
		END IF;
	END IF;
	
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 AND OLD.STATUS = 2 THEN
		IF EXISTS(SELECT 1 FROM pembayaran.pembatalan_tagihan WHERE TAGIHAN = OLD.ID AND STATUS = 1) THEN
			UPDATE pembayaran.pembayaran_tagihan SET STATUS = 0 WHERE TAGIHAN = OLD.ID;
			
			IF OLD.JENIS = 1 THEN
				
				
				
				UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
				   SET p.STATUS = 1
				 WHERE tp.PENDAFTARAN = p.NOMOR
				   AND tp.`STATUS` = 1
					AND tp.TAGIHAN = OLD.ID;
			END IF;
		END IF;							
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
