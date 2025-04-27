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

-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanRL38
DROP PROCEDURE IF EXISTS `LaporanRL38`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL38`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	
	DECLARE TAHUN INT;
	
	SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.KODE, rl.DESKRIPSI, ''',TAHUN,''' TAHUN, SUM(IF(rl38.JUMLAH IS NULL,0, rl38.JUMLAH)) JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT tindk.ID, refrl.KODE_HIRARKI, COUNT(tm.TINDAKAN) JUMLAH
			  				 FROM layanan.tindakan_medis tm
			  				 	 , master.rl38_tindakan tindk
			  				 	 , master.refrl refrl 
							 WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
							 	AND tindk.RL38=refrl.ID AND refrl.JENISRL=100103 AND refrl.IDJENISRL=8
							  GROUP BY tindk.ID
			  				 ) rl38 ON rl38.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=8
		 GROUP BY rl.ID
		 ORDER BY rl.ID');
			
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure laporan.LaporanRL39
DROP PROCEDURE IF EXISTS `LaporanRL39`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL39`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN
	DECLARE TAHUN INT;
	
	SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.KODE, rl.DESKRIPSI, ''',TAHUN,''' TAHUN, SUM(IF(rl39.JUMLAH IS NULL,0, rl39.JUMLAH)) JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT tindk.ID, refrl.KODE_HIRARKI, COUNT(tm.TINDAKAN) JUMLAH
			  				 FROM layanan.tindakan_medis tm
			  				 	 , master.rl39_tindakan tindk
			  				 	 , master.refrl refrl 
							 WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
							 	AND tindk.RL39=refrl.ID AND refrl.JENISRL=100103 AND refrl.IDJENISRL=9
							  GROUP BY tindk.ID
			  				 ) rl39 ON rl39.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=9
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
