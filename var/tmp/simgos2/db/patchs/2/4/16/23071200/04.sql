-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.32 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk trigger bpjs.klaim_after_insert
DROP TRIGGER IF EXISTS `klaim_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `klaim_after_insert` AFTER INSERT ON `klaim` FOR EACH ROW BEGIN
	UPDATE inacbg.hasil_grouping hg
      SET hg.KLAIM = NEW.status_id
    WHERE hg.NOSEP = NEW.noSEP;
    
   # Update ke tagihan klaim di pembayaran
   UPDATE inacbg.hasil_grouping hg, pembayaran.tagihan_klaim tk
      SET tk.`STATUS` = NEW.status_id
    WHERE hg.NOSEP = NEW.noSEP
	   AND tk.TAGIHAN = hg.TAGIHAN_ID;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger bpjs.klaim_after_update
DROP TRIGGER IF EXISTS `klaim_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `klaim_after_update` AFTER UPDATE ON `klaim` FOR EACH ROW BEGIN
	UPDATE inacbg.hasil_grouping hg
      SET hg.KLAIM = NEW.status_id
    WHERE hg.NOSEP = OLD.noSEP;
    
    # Update ke tagihan klaim di pembayaran
   UPDATE inacbg.hasil_grouping hg, pembayaran.tagihan_klaim tk
      SET tk.`STATUS` = NEW.status_id
    WHERE hg.NOSEP = OLD.noSEP
	   AND tk.TAGIHAN = hg.TAGIHAN_ID;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
