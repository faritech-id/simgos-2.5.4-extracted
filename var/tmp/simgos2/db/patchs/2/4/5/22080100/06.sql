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


-- Membuang struktur basisdata untuk layanan
CREATE DATABASE IF NOT EXISTS `layanan`;
USE `layanan`;

-- membuang struktur untuk trigger layanan.onAfterUpdateTindakanMedis
DROP TRIGGER IF EXISTS `onAfterUpdateTindakanMedis`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTindakanMedis` AFTER UPDATE ON `tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VKELAS TINYINT DEFAULT 0;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS
		  FROM pendaftaran.kunjungan k
		  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
				 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
		  		 master.ruangan r
		 WHERE k.RUANGAN = r.ID
		   AND k.NOMOR = NEW.KUNJUNGAN;
		
		IF FOUND_ROWS() > 0 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF VTAGIHAN != '' THEN
					CALL pembayaran.batalRincianTagihan(VTAGIHAN, OLD.ID, 3);
				END IF;
			END IF;
		END IF;
		
		-- Jika batal tindakan lab maka kirim ulang order ke lis untuk di batalkan
		IF EXISTS(SELECT 1 FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'lis') THEN
			UPDATE lis.order_item_log
			   SET STATUS = 1
			WHERE HIS_ID = NEW.ID;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
