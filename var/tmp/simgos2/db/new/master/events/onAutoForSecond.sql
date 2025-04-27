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

-- membuang struktur untuk event master.onAutoForSecond
DROP EVENT IF EXISTS `onAutoForSecond`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` EVENT `onAutoForSecond` ON SCHEDULE EVERY 1 SECOND STARTS '2013-09-10 14:22:25' ON COMPLETION PRESERVE ENABLE DO BEGIN
	DECLARE vtanggal DATE;
	
	SELECT TANGGAL INTO vtanggal
	  FROM master.tanggal
	 WHERE TANGGAL = DATE_FORMAT(NOW(), '%Y-%m-%d');
	 
	IF FOUND_ROWS() = 0 THEN
		INSERT INTO master.tanggal(TANGGAL, NAMAHARI)
			VALUES(DATE_FORMAT(NOW(), '%Y-%m-%d'), DAYNAME(NOW()));
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
