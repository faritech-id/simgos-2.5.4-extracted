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

-- membuang struktur untuk trigger medicalrecord.onBeforeInsertDiagnosa
DROP TRIGGER IF EXISTS `onBeforeInsertDiagnosa`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onBeforeInsertDiagnosa` BEFORE INSERT ON `diagnosa` FOR EACH ROW BEGIN
	DECLARE VNORM INT;
	
	SET NEW.KODE = UCASE(NEW.KODE);
	
	SELECT NORM INTO VNORM
	  FROM pendaftaran.pendaftaran
	 WHERE NOMOR = NEW.NOPEN;
	
	IF FOUND_ROWS() > 0 THEN
		SELECT NORM INTO VNORM 
		  FROM pendaftaran.pendaftaran a, medicalrecord.diagnosa b
		 WHERE a.NORM =  VNORM
		   AND a.NOMOR = b.NOPEN
		   AND b.KODE = NEW.KODE
		   AND b.`STATUS` = 1
		 ORDER BY b.ID LIMIT 1;
		 
		IF FOUND_ROWS() = 0 THEN
			SET NEW.BARU = 1;
		ELSE
			SET NEW.BARU = 0;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
