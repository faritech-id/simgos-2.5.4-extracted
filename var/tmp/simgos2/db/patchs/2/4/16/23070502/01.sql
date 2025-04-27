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

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk trigger master.onAfterUpdatePegawai
DROP TRIGGER IF EXISTS `onAfterUpdatePegawai`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdatePegawai` AFTER UPDATE ON `pegawai` FOR EACH ROW BEGIN		
	IF NEW.NIP != OLD.NIP THEN
		IF EXISTS(SELECT 1 FROM `master`.dokter WHERE NIP = OLD.NIP) AND NEW.PROFESI = 4 THEN
			UPDATE `master`.dokter SET NIP = NEW.NIP WHERE NIP = OLD.NIP;
		END IF;
		
		IF EXISTS(SELECT 1 FROM `master`.perawat WHERE NIP = OLD.NIP) 
			AND EXISTS(SELECT 1 FROM `master`.paramedis_map WHERE ID = NEW.PROFESI) THEN
			UPDATE `master`.perawat SET NIP = NEW.NIP WHERE NIP = OLD.NIP;
		END IF;
		
		IF EXISTS(SELECT 1 FROM aplikasi.pengguna WHERE NIP = OLD.NIP) THEN
			UPDATE aplikasi.pengguna SET NIP = NEW.NIP WHERE NIP = OLD.NIP;
		END IF;
		
		UPDATE `master`.staff SET NIP = NEW.NIP WHERE NIP = OLD.NIP;
	END IF;
	
	IF OLD.PROFESI != NEW.PROFESI THEN
		IF (NOT EXISTS(SELECT 1 FROM `master`.dokter WHERE NIP = OLD.NIP)) AND NEW.PROFESI = 4 THEN
			INSERT INTO `master`.dokter(NIP) VALUES(OLD.NIP);
		ELSE
			IF NEW.PROFESI != 4 THEN
				UPDATE `master`.dokter SET STATUS = 0 WHERE NIP = OLD.NIP;
			ELSE
				UPDATE `master`.dokter SET STATUS = 1 WHERE NIP = OLD.NIP;
			END IF;
		END IF;
		
		IF (NOT EXISTS(SELECT 1 FROM `master`.perawat WHERE NIP = OLD.NIP)) AND EXISTS(SELECT 1 FROM `master`.paramedis_map WHERE ID = NEW.PROFESI) THEN
			INSERT INTO `master`.perawat(NIP) VALUES(OLD.NIP);
		ELSE
			IF NOT EXISTS(SELECT 1 FROM `master`.paramedis_map WHERE ID = NEW.PROFESI) THEN
				UPDATE `master`.perawat SET STATUS = 0 WHERE NIP = OLD.NIP;
			ELSE
				UPDATE `master`.perawat SET STATUS = 1 WHERE NIP = OLD.NIP;
			END IF;
		END IF;
		
		IF (NOT EXISTS(SELECT 1 FROM `master`.staff WHERE NIP = OLD.NIP)) AND (NOT EXISTS(SELECT 1 FROM `master`.paramedis_map WHERE ID = NEW.PROFESI) OR NEW.PROFESI = 4) THEN
			INSERT INTO `master`.staff(NIP) VALUES(OLD.NIP);
		ELSE
			IF EXISTS(SELECT 1 FROM `master`.paramedis_map WHERE ID = NEW.PROFESI) OR NEW.PROFESI = 4 THEN
				UPDATE `master`.staff SET STATUS = 0 WHERE NIP = OLD.NIP;
			ELSE
				UPDATE `master`.staff SET STATUS = 1 WHERE NIP = OLD.NIP;
			END IF;
		END IF;
	END IF;
	
	IF NEW.SMF != OLD.SMF THEN
		IF NEW.SMF = 0 THEN
			UPDATE `master`.dokter_smf ds
			   SET ds.STATUS = 0		
			 WHERE EXISTS(SELECT 1 FROM `master`.dokter d WHERE d.ID = ds.DOKTER AND d.NIP = NEW.NIP);
		ELSE
			IF EXISTS(SELECT 1 FROM `master`.dokter_smf ds, `master`.dokter d WHERE ds.DOKTER = d.ID AND d.NIP = NEW.NIP) THEN
				UPDATE `master`.dokter_smf ds
				   SET ds.SMF = NEW.SMF,
				       ds.STATUS = 1
				 WHERE EXISTS(SELECT 1 FROM `master`.dokter d WHERE d.ID = ds.DOKTER AND d.NIP = NEW.NIP);			
			ELSE
				INSERT INTO `master`.dokter_smf(DOKTER, SMF)
				SELECT ID, NEW.SMF FROM `master`.dokter WHERE NIP = NEW.NIP;
			END IF;
		END IF;
	END IF;
	
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 0 THEN
		UPDATE `master`.dokter SET STATUS = 0 WHERE NIP = NEW.NIP;
		UPDATE `master`.dokter_ruangan a, `master`.dokter b
		   SET a.STATUS = 0
		 WHERE a.DOKTER = b.ID
		   AND b.NIP = NEW.NIP;
		   
		UPDATE `master`.perawat SET STATUS = 0 WHERE NIP = NEW.NIP;
		UPDATE `master`.perawat_ruangan a, `master`.perawat b
		   SET a.STATUS = 0
		 WHERE a.PERAWAT = b.ID
		   AND b.NIP = NEW.NIP;
		   
		UPDATE `master`.staff SET STATUS = 0 WHERE NIP = NEW.NIP;
		UPDATE `master`.staff_ruangan a, `master`.staff b
		   SET a.STATUS = 0
		 WHERE a.STAFF = b.ID
		   AND b.NIP = NEW.NIP;
	END IF;
	
	IF OLD.NIP != NEW.NIP OR OLD.NAMA != NEW.NAMA OR OLD.STATUS != NEW.STATUS THEN
		UPDATE aplikasi.pengguna p
		   SET p.NIP = NEW.NIP,
		   	 p.NAMA = NEW.NAMA,
				 p.STATUS = NEW.STATUS
		 WHERE p.NIP = OLD.NIP;		   	 
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
