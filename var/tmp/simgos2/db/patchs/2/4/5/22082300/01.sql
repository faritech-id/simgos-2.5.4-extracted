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

-- membuang struktur untuk trigger layanan.petugas_tindakan_medis_after_insert
DROP TRIGGER IF EXISTS `petugas_tindakan_medis_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `petugas_tindakan_medis_after_insert` AFTER INSERT ON `petugas_tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VKUNJUNGAN CHAR(19);				
	
	IF NEW.JENIS = 1 AND NEW.KE = 1 THEN
		SELECT tm.KUNJUNGAN INTO VKUNJUNGAN
		  FROM layanan.tindakan_medis tm,
		  		 pendaftaran.kunjungan k,
				 master.ruangan r		  		 
		 WHERE tm.ID = NEW.TINDAKAN_MEDIS
		   AND k.NOMOR = tm.KUNJUNGAN
			AND r.ID = k.RUANGAN
			AND r.JENIS_KUNJUNGAN = 4;
		 
		IF FOUND_ROWS() > 0 THEN
			INSERT INTO aplikasi.automaticexecute(PERINTAH)
			VALUES(CONCAT("INSERT INTO layanan.petugas_tindakan_medis(TINDAKAN_MEDIS, JENIS, MEDIS, KE, STATUS)
				SELECT tm.ID, 1, ", NEW.MEDIS, ", 1, 1
				  FROM layanan.tindakan_medis tm
				  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS = tm.ID
				 WHERE tm.KUNJUNGAN = '", VKUNJUNGAN, "'
				 	AND tm.STATUS = 1
				 	AND NOT tm.ID = '", NEW.TINDAKAN_MEDIS, "'
				   AND ptm.TINDAKAN_MEDIS IS NULL"));
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
