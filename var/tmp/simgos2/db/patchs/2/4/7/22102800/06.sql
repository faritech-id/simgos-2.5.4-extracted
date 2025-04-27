-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk kemkes-sirs
CREATE DATABASE IF NOT EXISTS `kemkes-sirs` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `kemkes-sirs`;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL13
DROP PROCEDURE IF EXISTS `ambilDataRL13`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL13`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL13;
	
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL13 ENGINE=MEMORY
	SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI, SUM(JUMLAH) JUMLAH
			 , SUM(VVIP) VVIP, SUM(VIP) VIP, SUM(KLSI) KLSI, SUM(KLSII) KLSII, SUM(KLSIII) KLSIII, SUM(KLSKHUSUS) KLSKHUSUS
	  FROM master.jenis_laporan_detil jrl
			 , master.refrl rl
		  	 LEFT JOIN (
				SELECT rlr.RL13, COUNT(rkt.ID) JUMLAH
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
				 WHERE rkt.`STATUS` != 0 
				  AND rkt.RUANG_KAMAR=rk.ID 
				  AND rk.`STATUS` != 0
				 GROUP BY rlr.RL13
			) rl13 ON rl13.RL13=rl.ID
		, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
			  FROM aplikasi.instansi ai
					 , master.ppk p
					 , master.wilayah w
			 WHERE ai.PPK=p.ID 
			   AND p.WILAYAH=w.ID) INST
	WHERE jrl.JENIS = rl.JENISRL 
	  AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS = '100101' 
	 AND jrl.ID = 3
	GROUP BY rl.ID
	ORDER BY rl.ID;
	
	INSERT INTO `kemkes-sirs`.`rl1-3`(tahun, `no`, jenis_pelayanan, jumlah_tt, vvip, vip, i, ii, iii, kelas_khusus)
	SELECT TAHUN
			 , KODE 
			 , DESKRIPSI
			 , JUMLAH
			 , VVIP
		    , VIP
		    , KLSI
		    , KLSII
		    , KLSIII
		    , KLSKHUSUS
     FROM TEMP_LAPORAN_RL13 t 
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl1-3` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);
	 
	UPDATE `kemkes-sirs`.`rl1-3` r, TEMP_LAPORAN_RL13 t
		SET r.jumlah_tt = t.JUMLAH,
			 r.vvip = t.VVIP,
			 r.vip = t.VIP,
			 r.i = t.KLSI,
			 r.ii = t.KLSII,
			 r.iii = t.KLSIII,
			 r.kelas_khusus = t.KLSKHUSUS
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
