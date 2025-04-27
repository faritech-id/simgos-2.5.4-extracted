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

-- membuang struktur untuk event informasi.refreshDataToday
DROP EVENT IF EXISTS `refreshDataToday`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` EVENT `refreshDataToday` ON SCHEDULE EVERY 15 SECOND STARTS '2014-12-10 13:02:08' ON COMPLETION PRESERVE ENABLE DO BEGIN
	CALL informasi.executePengunjung(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeKunjungan(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executePasienRawatInap(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executePenunjang(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executePendapatan(DATE(NOW()), DATE(NOW()));
	
	
	
	CALL informasi.executeKlaimInacbg(DATE(NOW()), DATE(NOW()));
	
	
	
	CALL informasi.execute10KlaimInacbgRJ(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.execute10KlaimInacbgRI(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeIndikatorRS(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.execute10DiagnosaRJ(DATE(NOW()), DATE(NOW()));
	CALL informasi.execute10DiagnosaRD(DATE(NOW()), DATE(NOW()));
	CALL informasi.execute10DiagnosaRI(DATE(NOW()), DATE(NOW()));
	
	CALL informasi.executeBedMonitorKemkes(DATE(NOW()), DATE(NOW()));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
