-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for aplikasi
USE `aplikasi`;

-- Dumping structure for function aplikasi.aksesRuanganBerdasarkanJenis
DROP FUNCTION IF EXISTS `aksesRuanganBerdasarkanJenis`;
DELIMITER //
CREATE FUNCTION `aksesRuanganBerdasarkanJenis`(
	`PPENGGUNA` INT
) RETURNS char(5) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE FOUNT CHAR(5);
	
	SELECT 
		IF(COUNT(*) > 0, 'TRUE', 'FALSE')
		INTO
		FOUNT
	FROM aplikasi.pengguna_akses_ruangan par
	LEFT JOIN `master`.ruangan r ON r.ID = par.RUANGAN 
	WHERE par.PENGGUNA = PPENGGUNA 
		AND r.JENIS_KUNJUNGAN = 4 
		AND r.JENIS = 5
		AND par.`STATUS` = 1
		AND r.`STATUS` = 1
		LIMIT 1;
	
	RETURN FOUNT;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
