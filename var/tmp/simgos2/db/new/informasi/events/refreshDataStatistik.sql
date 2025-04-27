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

-- membuang struktur untuk event informasi.refreshDataStatistik
DROP EVENT IF EXISTS `refreshDataStatistik`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` EVENT `refreshDataStatistik` ON SCHEDULE EVERY 3 MINUTE STARTS '2018-10-18 16:44:05' ON COMPLETION PRESERVE ENABLE DO BEGIN
	DECLARE VTGL_AWAL DATE;
	
	SET VTGL_AWAL = DATE_FORMAT(DATE(NOW()), '%Y-%m-01');
	
	CALL informasi.executeStatistiKunjungan(VTGL_AWAL, DATE(NOW()));
	
	CALL informasi.executeStatistikIndikator(VTGL_AWAL, DATE(NOW()));
	
	CALL informasi.executeStatistikKematian(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeStatistikRujukan(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeStatistik10BesarPenyakit(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeStatistik10BesarPenyakitRujukan(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeStatistikGolDarah(DATE(NOW()), DATE(NOW()));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
