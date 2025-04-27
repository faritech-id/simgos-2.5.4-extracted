-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk kemkes
USE `kemkes`;

-- membuang struktur untuk trigger kemkes.pasien_tb_before_insert
DROP TRIGGER IF EXISTS `pasien_tb_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pasien_tb_before_insert` BEFORE INSERT ON `pasien_tb` FOR EACH ROW BEGIN
	DECLARE VTIPE, VJML TINYINT;
	
	IF NOT NEW.kode_icd_x IS NULL AND NEW.kode_icd_x <> '' THEN 
		SELECT COUNT(*), tb.TIPE_DIAGNOSIS INTO VJML, VTIPE
		  FROM kemkes.icd_tb tb
		 WHERE tb.KODE = NEW.kode_icd_x;
		 
		IF VJML = 0 THEN
			SET VTIPE = 0;
		END IF;
		
		SET NEW.tipe_diagnosis = VTIPE;
	END IF;
	
	IF NOT NEW.tanggal_hasil_akhir_pengobatan IS NULL THEN
	   SET NEW.final = 1;
	END IF;
	
	SET NEW.kd_wasor = NEW.kd_kabupaten_faskes;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
