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

-- membuang struktur untuk function generator.generateIdKeluargaPasien
DROP FUNCTION IF EXISTS `generateIdKeluargaPasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `generateIdKeluargaPasien`(`PSHDK` SMALLINT, `PNORM` INT, `PJENIS_KELAMIN` TINYINT) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	INSERT INTO generator.id_keluarga_pasien(SHDK, NORM, JENIS_KELAMIN)
	VALUES(PSHDK, PNORM, PJENIS_KELAMIN);
		
	RETURN LAST_INSERT_ID();
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
