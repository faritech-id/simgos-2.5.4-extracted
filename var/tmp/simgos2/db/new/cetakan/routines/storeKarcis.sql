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

-- membuang struktur untuk procedure cetakan.storeKarcis
DROP PROCEDURE IF EXISTS `storeKarcis`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeKarcis`(IN `PNOPEN` CHAR(10), IN `PJENIS` TINYINT, IN `POLEH` SMALLINT)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM cetakan.karcis_pasien WHERE NOPEN = PNOPEN AND JENIS = PJENIS AND STATUS = 1) THEN
		INSERT INTO cetakan.karcis_pasien(ID, NOPEN, JENIS, TANGGAL, OLEH)
		VALUES(generator.generateIdKarcis(DATE(NOW())), PNOPEN, PJENIS, NOW(), POLEH);
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
