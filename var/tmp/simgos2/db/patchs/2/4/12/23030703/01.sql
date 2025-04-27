-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pendaftaran
USE `pendaftaran`;

-- Dumping structure for trigger pendaftaran.onAfterUpdateMutasi
DROP TRIGGER IF EXISTS `onAfterUpdateMutasi`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateMutasi` AFTER UPDATE ON `mutasi` FOR EACH ROW BEGIN
	DECLARE RKT INT;
	IF NOT OLD.RESERVASI IS NULL OR OLD.RESERVASI != '' THEN
		SELECT RUANG_KAMAR_TIDUR INTO RKT FROM pendaftaran.reservasi WHERE NOMOR = OLD.RESERVASI;
		
		IF FOUND_ROWS() > 0 THEN
			IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 0 THEN
				UPDATE pendaftaran.reservasi SET STATUS = 0 WHERE NOMOR = OLD.RESERVASI;
				-- UPDATE master.ruang_kamar_tidur SET STATUS = 1 WHERE ID = RKT;				
			END IF;
		END IF;
	END IF;
	
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 2 THEN
		INSERT INTO aplikasi.automaticexecute(PERINTAH)
		VALUES(CONCAT("UPDATE pendaftaran.kunjungan SET STATUS = 2 WHERE NOMOR = '", OLD.KUNJUNGAN, "'"));
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
