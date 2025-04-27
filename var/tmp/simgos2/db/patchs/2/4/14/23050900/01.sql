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


-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk trigger pendaftaran.onBeforeInsertAntrianRuangan
DROP TRIGGER IF EXISTS `onBeforeInsertAntrianRuangan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onBeforeInsertAntrianRuangan` BEFORE INSERT ON `antrian_ruangan` FOR EACH ROW BEGIN
	DECLARE VUSING_GENERATOR TINYINT DEFAULT 1;
	
	IF NEW.TANGGAL IS NULL THEN
		SET NEW.TANGGAL = DATE(NOW());
	END IF;
	
	IF EXISTS(
	   SELECT 1
		  FROM aplikasi.properti_config pc
		 WHERE pc.ID = 64
		   AND VALUE = 'TRUE'
	) THEN
		IF EXISTS(
			SELECT 1
			  FROM information_schema.`TABLES` t
			 WHERE t.TABLE_SCHEMA = 'regonline'
			   AND t.TABLE_NAME = 'reservasi'
		) THEN
		BEGIN
			DECLARE VNORM INT;
			DECLARE VNIK CHAR(16);
			DECLARE VNOMOR SMALLINT;
			DECLARE VPOS CHAR(3);
			
			IF EXISTS(
				SELECT 1
				  FROM `master`.ruangan r
				 WHERE r.ID = NEW.RUANGAN
				   AND r.JENIS_KUNJUNGAN = 1
				 LIMIT 1
			) THEN
				SELECT p.NORM, kip.NOMOR
				  INTO VNORM, VNIK
				  FROM pendaftaran.pendaftaran p
				       LEFT JOIN `master`.kartu_identitas_pasien kip
				       		  ON kip.NORM = p.NORM AND kip.JENIS = 1
				 WHERE p.NOMOR = NEW.REF;
				
				IF NOT VNORM IS NULL THEN
					SELECT CONCAT(r.POS_ANTRIAN, r.CARABAYAR), r.NO
					  INTO VPOS, VNOMOR
					  FROM regonline.reservasi r
					 WHERE r.NORM = VNORM
					   AND r.TANGGALKUNJUNGAN = NEW.TANGGAL
					   AND r.POLI = NEW.RUANGAN
					 ORDER BY r.TGL_DAFTAR DESC
					 LIMIT 1;
					 
					IF VNOMOR IS NULL THEN
						IF NOT VNIK IS NULL THEN
							SELECT CONCAT(r.POS_ANTRIAN, r.CARABAYAR), r.NO
							  INTO VPOS, VNOMOR
							  FROM regonline.reservasi r
							 WHERE r.NIK = VNIK
							   AND r.TANGGALKUNJUNGAN = NEW.TANGGAL
							   AND r.POLI = NEW.RUANGAN
							 ORDER BY r.TGL_DAFTAR DESC
							 LIMIT 1;
						END IF;
					END IF;
					 
					IF NOT VNOMOR IS NULL THEN
						SET NEW.NOMOR = VNOMOR;
						SET NEW.POS = VPOS;
						SET VUSING_GENERATOR = 0;	
					END IF;
				END IF;
			END IF;
		END;
		END IF;
	END IF;
	
	IF VUSING_GENERATOR = 1 THEN
		SET NEW.NOMOR = generator.generateNoAntrianRuangan(NEW.RUANGAN, NEW.TANGGAL);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
