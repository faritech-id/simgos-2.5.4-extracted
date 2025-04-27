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

-- membuang struktur untuk function aplikasi.isSelectedPenggunaAkses
DROP FUNCTION IF EXISTS `isSelectedPenggunaAkses`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `isSelectedPenggunaAkses`(`PPENGGUNA` SMALLINT, `PMODULE` CHAR(10), `PGROUP_PENGGUNA` SMALLINT) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	DECLARE VAKSES TINYINT DEFAULT FALSE;
	
	IF EXISTS(
		SELECT 1
		  FROM aplikasi.pengguna_akses a, aplikasi.group_pengguna_akses_module b
		 WHERE a.GROUP_PENGGUNA_AKSES_MODULE = b.ID
		   AND a.PENGGUNA = PPENGGUNA 
			AND b.MODUL = PMODULE
			AND b.GROUP_PENGGUNA = PGROUP_PENGGUNA
			AND a.STATUS = 1 AND b.`STATUS` = 1) THEN
		SET VAKSES = TRUE;
	END IF;
	
	RETURN VAKSES;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
