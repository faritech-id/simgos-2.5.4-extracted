-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pembatalan
USE `pembatalan`;

-- Dumping structure for trigger pembatalan.pembatalan_final_hasil_after_insert
DROP TRIGGER IF EXISTS `pembatalan_final_hasil_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pembatalan_final_hasil_after_insert` AFTER INSERT ON `pembatalan_final_hasil` FOR EACH ROW BEGIN
	IF NOT NEW.REF = '' THEN
	BEGIN
		DECLARE VJENIS_KUNJUNGAN TINYINT;
		
		SELECT r.JENIS_KUNJUNGAN
		  INTO VJENIS_KUNJUNGAN
		  FROM pendaftaran.kunjungan k,
		  		 `master`.ruangan r
		 WHERE k.NOMOR = NEW.KUNJUNGAN
		   AND r.ID = k.RUANGAN;
		   
		IF NOT VJENIS_KUNJUNGAN IS NULL THEN
		   
			IF VJENIS_KUNJUNGAN = 5 THEN
				 UPDATE layanan.hasil_rad 
				    SET STATUS = 1
				  WHERE ID = NEW.REF;
			END IF;
			
			IF EXISTS(SELECT 1 FROM medicalrecord.operasi WHERE ID = NEW.REF) AND VJENIS_KUNJUNGAN != 5  THEN
				 UPDATE medicalrecord.operasi 
				    SET STATUS = 1
				  WHERE ID = NEW.REF;
			END IF;
		END IF;
	END;
	ELSE
		UPDATE pendaftaran.kunjungan k
		   SET k.FINAL_HASIL = 0
		 WHERE k.NOMOR = NEW.KUNJUNGAN;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
