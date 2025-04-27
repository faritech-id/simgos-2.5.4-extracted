-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.5.0.6677
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
				AND tp.TAGIHAN = OLD.ID
				AND tp.REF = '';
				
			UPDATE pembayaran.pembatalan_tagihan
			   SET STATUS = 2
			 WHERE TAGIHAN = OLD.ID
			   AND STATUS = 1;
		
		ELSEIF OLD.JENIS = 2 THEN
			UPDATE pembayaran.pelunasan_piutang_pasien
			   SET STATUS = 2
			 WHERE ID = OLD.REF;
		
		ELSEIF OLD.JENIS = 3 THEN
			UPDATE pembayaran.pelunasan_piutang_perusahaan
			   SET STATUS = 2
			 WHERE ID = OLD.REF;
			 
		ELSEIF OLD.JENIS = 4 THEN
			UPDATE penjualan.penjualan
			   SET STATUS = 2
			 WHERE NOMOR = OLD.ID;
		END IF;
	END IF;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 AND OLD.STATUS = 2 THEN
	BEGIN
		DECLARE VJENIS TINYINT DEFAULT 1;
		DECLARE VSTATUS TINYINT DEFAULT 1;
		
		SELECT pt.JENIS
		  INTO VJENIS
		  FROM pembayaran.pembatalan_tagihan pt 
		 WHERE pt.TAGIHAN = OLD.ID 
		   AND pt.STATUS = 1
		 LIMIT 1;
		 
		IF NOT VJENIS IS NULL THEN
			SET VSTATUS = IF(VJENIS = 1, 1, 0);
			UPDATE pembayaran.pembayaran_tagihan 
			   SET STATUS = VSTATUS 
			 WHERE TAGIHAN = OLD.ID
			   AND JENIS IN (1, 8)
			   AND STATUS = 2;
			
			IF OLD.JENIS = 1 THEN				
				UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
				   SET p.STATUS = 1
				 WHERE tp.PENDAFTARAN = p.NOMOR
				   AND tp.`STATUS` = 1
				   AND tp.TAGIHAN = OLD.ID
                   AND tp.REF = '';
			END IF;
			
			IF OLD.JENIS = 2 THEN
				UPDATE pembayaran.pelunasan_piutang_pasien
				   SET STATUS = 1
				 WHERE ID = OLD.REF;
			END IF;
			
			IF OLD.JENIS = 3 THEN
				UPDATE pembayaran.pelunasan_piutang_perusahaan
				   SET STATUS = 1
				 WHERE ID = OLD.REF;
			END IF;
		END IF;
	END;						
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
