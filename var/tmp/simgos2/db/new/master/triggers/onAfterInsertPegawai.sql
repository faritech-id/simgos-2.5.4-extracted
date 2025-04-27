-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk trigger master.onAfterInsertPegawai
DROP TRIGGER IF EXISTS `onAfterInsertPegawai`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onAfterInsertPegawai` AFTER INSERT ON `pegawai` FOR EACH ROW BEGIN
	
		
	IF NOT EXISTS(SELECT 1 FROM master.dokter WHERE NIP = NEW.NIP) AND NEW.PROFESI = 4 THEN
		INSERT INTO master.dokter(NIP) VALUES(NEW.NIP);
	ELSEIF NOT EXISTS(SELECT 1 FROM master.perawat WHERE NIP = NEW.NIP) 
		AND EXISTS(SELECT 1 FROM master.paramedis_map WHERE ID = NEW.PROFESI) THEN
		INSERT INTO master.perawat(NIP) VALUES(NEW.NIP);
	ELSE
		INSERT INTO master.staff(NIP) VALUES(NEW.NIP);
	END IF;
	
	IF NEW.SMF > 0 THEN
		INSERT INTO master.dokter_smf(DOKTER, SMF)
		SELECT ID, NEW.SMF FROM master.dokter WHERE NIP = NEW.NIP;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
