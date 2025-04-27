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

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL2
DROP PROCEDURE IF EXISTS `ambilDataRL2`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL2`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL2;
	
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL2 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN
			 , SUM(IF(PRIA IS NULL,0,PRIA)) PRIA
			 , SUM(IF(WANITA IS NULL,0,WANITA)) WANITA
			 , 0 BUTUHLK, 0 BUTUHPR, 0 KURANGLK, 0 KURANGPR
	  FROM master.jenis_laporan_detil jrl
			 , master.refrl rl
			 LEFT JOIN (
			 	SELECT refrl.KODE_HIRARKI, rl2.RL2, SUM(IF(p.JENIS_KELAMIN=1,1,0)) PRIA, SUM(IF(p.JENIS_KELAMIN=2,1,0)) WANITA
				  FROM master.pegawai p
						 , master.rl2_pegawai rl2
						 , master.refrl refrl
				 WHERE p.NIP = rl2.NIP 
				   AND rl2.RL2 = refrl.ID 
					AND refrl.JENISRL = '100102' 
					AND refrl.IDJENISRL = 1
				 GROUP BY rl2.RL2) rl2 ON rl2.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,'%')
			 , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				  FROM aplikasi.instansi ai
						 , master.ppk p
						 , master.wilayah w
				 WHERE ai.PPK = p.ID 
				   AND p.WILAYAH = w.ID) INST
		WHERE jrl.JENIS = rl.JENISRL 
		  AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS = '100102' 
		  AND jrl.ID = 1
		GROUP BY rl.ID
		ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl2`(tahun, `no_kode`, kualifikasi_pendidikan, keadaan_laki_laki, keadaan_perempuan, kebutuhan_laki_laki
	, kebutuhan_perempuan, kekurangan_laki_laki, kekurangan_perempuan)
	SELECT TAHUN
			 , KODE 
			 , DESKRIPSI
			 , PRIA
			 , WANITA
		    , BUTUHLK
		    , BUTUHPR
		    , KURANGLK
		    , KURANGPR
	  FROM TEMP_LAPORAN_RL2 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl2` r WHERE r.tahun = t.TAHUN AND r.no_kode = t.KODE);

	UPDATE `kemkes-sirs`.`rl2` r, TEMP_LAPORAN_RL2 t
		SET r.keadaan_laki_laki = t.PRIA,
			 r.keadaan_perempuan = t.WANITA,
			 r.kebutuhan_laki_laki = t.BUTUHLK,
			 r.kebutuhan_perempuan = t.BUTUHPR,
			 r.kekurangan_laki_laki = t.KURANGLK,
			 r.kekurangan_perempuan = t.KURANGPR
	WHERE r.tahun = t.TAHUN 
	  AND r.`no_kode` = t.KODE;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
