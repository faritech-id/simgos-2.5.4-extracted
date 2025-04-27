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

-- membuang struktur untuk event informasi.refreshDataTwoMonth
DROP EVENT IF EXISTS `refreshDataTwoMonth`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` EVENT `refreshDataTwoMonth` ON SCHEDULE EVERY 15 MINUTE STARTS '2014-12-11 08:56:33' ON COMPLETION PRESERVE ENABLE DO BEGIN
	DECLARE TGL_AWAL DATETIME;
	DECLARE TGL_AKHIR DATETIME;
	
	SET TGL_AWAL = DATE_FORMAT(DATE_SUB(DATE(NOW()), INTERVAL 1 MONTH), '%Y-%m-01');
	SET TGL_AKHIR = DATE_SUB(DATE(NOW()), INTERVAL 1 DAY);
	
	CALL informasi.executePengunjung(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.executeKunjungan(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.executePasienRawatInap(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.executePenunjang(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.executePendapatan(TGL_AWAL, TGL_AKHIR);
	
	
	
	CALL informasi.executeKlaimInacbg(TGL_AWAL, TGL_AKHIR);
	
	
	
	CALL informasi.execute10KlaimInacbgRJ(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.execute10KlaimInacbgRI(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.executeIndikatorRS(TGL_AWAL, TGL_AKHIR);
	
	CALL informasi.execute10DiagnosaRJ(TGL_AWAL, TGL_AKHIR);
	CALL informasi.execute10DiagnosaRD(TGL_AWAL, TGL_AKHIR);
	CALL informasi.execute10DiagnosaRI(TGL_AWAL, TGL_AKHIR);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
