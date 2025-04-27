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

-- membuang struktur untuk function pendaftaran.getLamaDirawatAturan1
DROP FUNCTION IF EXISTS `getLamaDirawatAturan1`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawatAturan1`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	RETURN DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
