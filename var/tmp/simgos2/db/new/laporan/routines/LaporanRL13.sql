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

-- membuang struktur untuk procedure laporan.LaporanRL13
DROP PROCEDURE IF EXISTS `LaporanRL13`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL13`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI, SUM(JUMLAH) JUMLAH
				, SUM(VVIP) VVIP, SUM(VIP) VIP, SUM(KLSI) KLSI, SUM(KLSII) KLSII, SUM(KLSIII) KLSIII, SUM(KLSKHUSUS) KLSKHUSUS
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT  rlr.RL13, COUNT(rkt.ID) JUMLAH
									  , SUM(IF(mapkls.RL_KELAS=1,1,0)) VVIP
									  , SUM(IF(mapkls.RL_KELAS=2,1,0)) VIP
									  , SUM(IF(mapkls.RL_KELAS=3,1,0)) KLSI
									  , SUM(IF(mapkls.RL_KELAS=4,1,0)) KLSII
									  , SUM(IF(mapkls.RL_KELAS=5,1,0)) KLSIII
									  , SUM(IF(mapkls.RL_KELAS=6,1,0)) KLSKHUSUS
								FROM master.ruang_kamar_tidur rkt
								   , master.ruang_kamar rk
									  LEFT JOIN master.kelas_simrs_rl mapkls ON rk.KELAS=mapkls.KELAS
									  LEFT JOIN master.rl13_ruangan rlr ON rk.RUANGAN=rlr.ID
								WHERE rkt.`STATUS`!=0 AND rkt.RUANG_KAMAR=rk.ID AND rk.`STATUS`!=0
								GROUP BY rlr.RL13
			  				) rl13 ON rl13.RL13=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100101'' AND jrl.ID=3
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
