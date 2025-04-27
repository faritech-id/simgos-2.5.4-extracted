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

-- membuang struktur untuk trigger layanan.onBeforeInsertPetugasTindakanMedis
DROP TRIGGER IF EXISTS `onBeforeInsertPetugasTindakanMedis`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onBeforeInsertPetugasTindakanMedis` BEFORE INSERT ON `petugas_tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VKE TINYINT;
	
	SELECT (MAX(KE) + 1) INTO VKE
	  FROM layanan.petugas_tindakan_medis 
	 WHERE TINDAKAN_MEDIS = NEW.TINDAKAN_MEDIS AND JENIS = NEW.JENIS
	   AND STATUS = 1;
	 
	SET NEW.KE = IF(VKE IS NULL, 1, VKE);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
