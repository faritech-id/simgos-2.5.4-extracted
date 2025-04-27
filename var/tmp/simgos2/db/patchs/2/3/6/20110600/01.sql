-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.24 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE layanan;

-- membuang struktur untuk function layanan.adaPetugasMedisYgTdkTerisi
DROP FUNCTION IF EXISTS `adaPetugasMedisYgTdkTerisi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `adaPetugasMedisYgTdkTerisi`(
	`PKUNJUNGAN` CHAR(19)
) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	IF EXISTS(SELECT 1
	  FROM layanan.tindakan_medis tm,
	  		 layanan.petugas_tindakan_medis ptm
	 WHERE tm.KUNJUNGAN = PKUNJUNGAN
	   AND tm.`STATUS` > 0
	   AND ptm.TINDAKAN_MEDIS = tm.ID
	   AND ptm.`STATUS` > 0
	   AND ptm.MEDIS = 0
	 LIMIT 1) THEN
	 	RETURN 1;
	END IF;
	
	RETURN 0;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
