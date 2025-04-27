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

-- membuang struktur untuk procedure informasi.list10DiagnosaRI
DROP PROCEDURE IF EXISTS `list10DiagnosaRI`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `list10DiagnosaRI`(IN `PTGL_AWAL` DATE, IN `PTGL_AKHIR` DATE, IN `PTYPE` TINYINT)
BEGIN
	
	
	IF PTYPE < 10 THEN
		SET @sqlText = CONCAT('
			SELECT  YEAR(TANGGAL) TAHUN, MONTH(TANGGAL) IDBULAN, b.NAMA BULAN, r.ID, DESKRIPSI, SUM(VALUE) VALUE , MAX(LASTUPDATED) LASTUPDATED
			  FROM informasi.diagnosa_ri r LEFT JOIN master.bulan b ON MONTH(TANGGAL) = b.ID
			 WHERE TANGGAL BETWEEN ''', PTGL_AWAL, ''' AND ''', PTGL_AKHIR, '''',
			 IF(PTYPE = 2, 'GROUP BY MONTH(TANGGAL), r.ID ',
			 	IF(PTYPE = 3, 'GROUP BY YEAR(TANGGAL), r.ID ',
			 		IF(PTYPE = 4, 'GROUP BY YEAR(TANGGAL), MONTH(TANGGAL), r.ID ',
			 			IF(PTYPE = 5, 'GROUP BY YEAR(TANGGAL), r.ID', 'GROUP BY r.ID ')
			 		)
			 	)
			 ),'
			 ORDER BY VALUE DESC LIMIT 10');
		 
	 	
		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt; 
	ELSE
	BEGIN 		
	END;
	END IF;		
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
