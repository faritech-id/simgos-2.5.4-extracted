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

-- membuang struktur untuk function aplikasi.isSelectedPenggunaAksesRuangan
DROP FUNCTION IF EXISTS `isSelectedPenggunaAksesRuangan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `isSelectedPenggunaAksesRuangan`(`PPENGGUNA` SMALLINT, `PRUANGAN` CHAR(10)) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	DECLARE VAKSES TINYINT DEFAULT FALSE;
	
	IF EXISTS(
		SELECT 1
		  FROM aplikasi.pengguna_akses_ruangan a
		 WHERE a.PENGGUNA = PPENGGUNA 
			AND a.RUANGAN = PRUANGAN
			AND a.STATUS = 1) THEN
			
		SET VAKSES = TRUE;
	END IF;
	
	RETURN VAKSES;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
