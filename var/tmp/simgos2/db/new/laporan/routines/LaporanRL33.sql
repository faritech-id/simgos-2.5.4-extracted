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

-- membuang struktur untuk procedure laporan.LaporanRL33
DROP PROCEDURE IF EXISTS `LaporanRL33`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL33`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	
	DECLARE TAHUN INT;
	
	SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.KODE, rl.DESKRIPSI, ''',TAHUN,''' TAHUN, SUM(IF(rl33.JUMLAH IS NULL,0,rl33.JUMLAH)) JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT tindk.RL33,COUNT(tm.TINDAKAN) JUMLAH
			  				 FROM layanan.tindakan_medis tm
			  				 	 , master.rl33_tindakan tindk 
							 WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
							  GROUP BY tindk.RL33) rl33 ON rl33.RL33=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=3
		GROUP BY rl.ID
		ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
