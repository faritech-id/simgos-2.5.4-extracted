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


-- Membuang struktur basisdata untuk lis
CREATE DATABASE IF NOT EXISTS `lis`;
USE `lis`;

-- membuang struktur untuk trigger lis.hasil_log_after_insert
DROP TRIGGER IF EXISTS `hasil_log_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_after_insert` AFTER INSERT ON `hasil_log` FOR EACH ROW BEGIN   
	-- Add parameter kode dan nama jika belum ada
	IF NOT EXISTS(SELECT 1 FROM lis.parameter_lis p WHERE p.VENDOR_ID = NEW.VENDOR_LIS AND p.KODE = NEW.LIS_KODE_TEST) THEN
		INSERT INTO lis.parameter_lis(VENDOR_ID, KODE, NAMA)
		VALUES(NEW.VENDOR_LIS, TRIM(NEW.LIS_KODE_TEST), TRIM(NEW.LIS_NAMA_TEST)); 
	END IF;
	
	-- Add mapping hasil
	IF NOT EXISTS(
		SELECT 1 
		  FROM lis.mapping_hasil mh 
		 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
		   AND mh.LIS_KODE_TEST = TRIM(NEW.LIS_KODE_TEST)
			AND mh.PREFIX_KODE = NEW.PREFIX_KODE
			AND mh.HIS_KODE_TEST = NEW.HIS_KODE_TEST) THEN
		INSERT INTO lis.mapping_hasil(`VENDOR_LIS`, LIS_KODE_TEST, PREFIX_KODE, HIS_KODE_TEST)
		VALUES(NEW.VENDOR_LIS, TRIM(NEW.LIS_KODE_TEST), NEW.PREFIX_KODE, HIS_KODE_TEST); 
	END IF;
	
	-- jika his no lab and his kode test valid 
	IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
		CALL lis.storeHasilLabToHIS(NEW.ID);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
