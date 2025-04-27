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

-- membuang struktur untuk function generator.generateNoKejadian
DROP FUNCTION IF EXISTS `generateNoKejadian`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `generateNoKejadian`(
	`PTAHUN` YEAR,
	`PBULAN` TINYINT
) RETURNS char(8) CHARSET latin1
    DETERMINISTIC
BEGIN
	INSERT INTO generator.no_kejadian(TAHUN, BULAN)
	VALUES(PTAHUN, PBULAN);
	
	RETURN CONCAT(IF(LENGTH(PTAHUN) = 4, RIGHT(PTAHUN, 2), LPAD(PTAHUN, 2, '0')), LPAD(PBULAN, 2, '0'), LPAD(LAST_INSERT_ID(), 4, '0'));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
