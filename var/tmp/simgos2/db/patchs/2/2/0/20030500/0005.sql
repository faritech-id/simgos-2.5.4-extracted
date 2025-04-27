-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk trigger bpjs.peserta_after_insert
DROP TRIGGER IF EXISTS `peserta_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `peserta_after_insert` AFTER INSERT ON `peserta` FOR EACH ROW BEGIN
	DECLARE VSUCCESS TINYINT DEFAULT TRUE;
		
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;		
	CALL `master`.storeJenisPeserta(2, NEW.kdJenisPeserta, NEW.nmJenisPeserta);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger bpjs.peserta_after_update
DROP TRIGGER IF EXISTS `peserta_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `peserta_after_update` AFTER UPDATE ON `peserta` FOR EACH ROW BEGIN
	DECLARE VSUCCESS TINYINT DEFAULT TRUE;
	
	IF NEW.kdJenisPeserta != OLD.kdJenisPeserta OR NEW.nmJenisPeserta != OLD.nmJenisPeserta THEN
	BEGIN					
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;		
		CALL `master`.storeJenisPeserta(2, NEW.kdJenisPeserta, NEW.nmJenisPeserta);
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
