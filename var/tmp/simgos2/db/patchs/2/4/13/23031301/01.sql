-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk trigger pembayaran.onAfterInsertPembayaranTagihan
DROP TRIGGER IF EXISTS `onAfterInsertPembayaranTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertPembayaranTagihan` AFTER INSERT ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.JENIS IN (1, 8) AND NEW.STATUS = 2 THEN 
		UPDATE pembayaran.tagihan
		   SET STATUS = 2
		 WHERE ID = NEW.TAGIHAN
		   AND STATUS = 1;
		   
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		VALUES(CONCAT("CALL pembayaran.procStoreTagihanKlaim('", DATE(NEW.TANGGAL), "', '", DATE(NEW.TANGGAL), "')"), 1);
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger pembayaran.pembayaran_tagihan_after_update
DROP TRIGGER IF EXISTS `pembayaran_tagihan_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pembayaran_tagihan_after_update` AFTER UPDATE ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
	   IF NEW.JENIS IN (1, 8) THEN  
			UPDATE pembayaran.tagihan
			   SET STATUS = 2
			 WHERE ID = NEW.TAGIHAN
			   AND STATUS = 1;
			
			INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
			VALUES(CONCAT("CALL pembayaran.procStoreTagihanKlaim('", DATE(NEW.TANGGAL), "', '", DATE(NEW.TANGGAL), "')"), 1);
		END IF;
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
