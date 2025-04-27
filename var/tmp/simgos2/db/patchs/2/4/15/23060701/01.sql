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

-- membuang struktur untuk trigger pendaftaran.onAfterInsertTujuanPasien
DROP TRIGGER IF EXISTS `onAfterInsertTujuanPasien`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertTujuanPasien` AFTER INSERT ON `tujuan_pasien` FOR EACH ROW BEGIN
	DECLARE VNORM INT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VNOMORANTRIANPOLI INT(30);
	
	INSERT INTO pendaftaran.antrian_ruangan(RUANGAN, JENIS, REF)
	VALUES(NEW.RUANGAN, 1, NEW.NOPEN);
	
	SELECT p.NORM, p.TANGGAL
	  INTO VNORM, VTANGGAL 
	  FROM pendaftaran.pendaftaran p
	 WHERE p.NOMOR = NEW.NOPEN
	LIMIT 1;
	
	IF NOT VNORM IS NULL THEN
		IF EXISTS(
			SELECT 1
			  FROM aplikasi.properti_config 
			 WHERE ID = 90085 
			   AND VALUE = 'TRUE'
		) THEN
			SET VNOMORANTRIANPOLI = regonline.generateNoAntrianPoli(NEW.RUANGAN, DATE(VTANGGAL));
			INSERT INTO regonline.antrian_poli(ASAL_REF, REF, NOMOR, POLI, TANGGAL, STATUS) 
			VALUES (2, NEW.NOPEN, VNOMORANTRIANPOLI, NEW.RUANGAN, DATE(VTANGGAL), 2);
		END IF;
		
		
		IF EXISTS(
			SELECT 1 
			  FROM `master`.ruangan r 
			 WHERE r.ID = NEW.RUANGAN 
			   AND r.JENIS_KUNJUNGAN = 2 
				AND r.STATUS = 1 
			 LIMIT 1
	   ) THEN
		BEGIN
			DECLARE VID_TRIAGE INT;
			DECLARE VTGL DATE;
			
			SELECT t.ID, STR_TO_DATE(REPLACE(t.KEDATANGAN->'$.TANGGAL', '"', ''), '%Y-%m-%d')
			  INTO VID_TRIAGE, VTGL
			  FROM medicalrecord.triage t
			 WHERE t.NORM = VNORM
			   AND t.`STATUS` = 1
			   AND (t.NOPEN IS NULL OR t.NOPEN = '')
			 ORDER BY t.TANGGAL DESC
			 LIMIT 1;
			   
			IF NOT VID_TRIAGE IS NULL THEN
				IF VTGL = DATE(VTANGGAL) THEN
					UPDATE medicalrecord.triage t
					   SET t.NOPEN = NEW.NOPEN,
					   	 t.STATUS = 2
					 WHERE t.ID = VID_TRIAGE
					   AND t.`STATUS` = 1;
				END IF;
			END IF;
		END;	
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
