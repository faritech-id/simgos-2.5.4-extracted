-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk trigger medicalrecord.onAfterInsertDiagKematian
DROP TRIGGER IF EXISTS `onAfterInsertDiagKematian`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertDiagKematian` AFTER INSERT ON `diagnosa_meninggal` FOR EACH ROW BEGIN

	IF NEW.UTAMA = 1 THEN
		INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
		VALUES(CONCAT("
			UPDATE medicalrecord.diagnosa_meninggal 
				SET UTAMA = 2 
			 WHERE NOPEN = '", NEW.NOPEN, "' AND NOT ID IN (",NEW.ID,");
		 "));
	END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger medicalrecord.onAfterInsertDiagnosa
DROP TRIGGER IF EXISTS `onAfterInsertDiagnosa`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertDiagnosa` AFTER INSERT ON `diagnosa` FOR EACH ROW BEGIN
	IF NEW.INA_GROUPER = 0 THEN
		IF NOT EXISTS(SELECT 1 FROM medicalrecord.diagnosa d WHERE d.NOPEN = NEW.NOPEN AND d.INA_GROUPER = 1 AND d.KODE = NEW.KODE AND d.STATUS = 1) THEN
			INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
			VALUES(CONCAT("INSERT INTO medicalrecord.diagnosa(NOPEN, KODE, `DIAGNOSA`, UTAMA, INACBG, TANGGAL, OLEH, `STATUS`, INA_GROUPER) 
				VALUES('", NEW.NOPEN, "', '", NEW.KODE, "', '", NEW.DIAGNOSA, "', ", NEW.UTAMA, ", ", NEW.INACBG, ", '", NEW.TANGGAL, "', ", NEW.OLEH, ", ", NEW.STATUS, ", 1);"
			));
		END IF;
	END IF;
	
	IF NEW.UTAMA = 1 THEN
		INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
		VALUES(CONCAT("
			UPDATE medicalrecord.diagnosa 
				SET UTAMA = 2 
			 WHERE NOPEN = '", NEW.NOPEN, "' 
			   AND INA_GROUPER = ", NEW.INA_GROUPER, "
			   AND NOT ID IN (",NEW.ID,");
		 "));
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger medicalrecord.onAfterUpdateDiagKematian
DROP TRIGGER IF EXISTS `onAfterUpdateDiagKematian`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateDiagKematian` AFTER UPDATE ON `diagnosa_meninggal` FOR EACH ROW BEGIN

	IF NEW.UTAMA = 1 THEN
		INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
		VALUES(CONCAT("
			UPDATE medicalrecord.diagnosa_meninggal 
				SET UTAMA = 2 
			 WHERE NOPEN = '", NEW.NOPEN, "' AND NOT ID IN (",NEW.ID,");
		 "));
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger medicalrecord.onAfterUpdateDiagnosa
DROP TRIGGER IF EXISTS `onAfterUpdateDiagnosa`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateDiagnosa` AFTER UPDATE ON `diagnosa` FOR EACH ROW BEGIN
	IF NEW.UTAMA = 1 THEN
		INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
		VALUES(CONCAT("
			UPDATE medicalrecord.diagnosa 
				SET UTAMA = 2 
			 WHERE NOPEN = '", OLD.NOPEN, "' 
			   AND INA_GROUPER = ", NEW.INA_GROUPER, "
			   AND NOT ID IN (",NEW.ID,");
		 "));
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger medicalrecord.prosedur_after_insert
DROP TRIGGER IF EXISTS `prosedur_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `prosedur_after_insert` AFTER INSERT ON `prosedur` FOR EACH ROW BEGIN
	IF NEW.INA_GROUPER = 0 THEN
		IF NOT EXISTS(SELECT 1 FROM medicalrecord.prosedur p WHERE p.NOPEN = NEW.NOPEN AND p.INA_GROUPER = 1 AND p.KODE = NEW.KODE AND p.STATUS = 1) THEN
			INSERT INTO aplikasi.automaticexecute_03(PERINTAH)
			VALUES(CONCAT("INSERT INTO medicalrecord.prosedur(NOPEN, KODE, `TINDAKAN`, INACBG, TANGGAL, OLEH, `STATUS`, INA_GROUPER) 
				VALUES('", NEW.NOPEN, "', '", NEW.KODE, "', '", NEW.TINDAKAN, "', ", NEW.INACBG, ", '", NEW.TANGGAL, "', ", NEW.OLEH, ", ", NEW.STATUS, ", 1);"
			));
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
