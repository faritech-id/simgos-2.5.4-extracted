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
USE `kemkes-sirs`;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL33
DROP PROCEDURE IF EXISTS `ambilDataRL33`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL33`(
	IN `PTAHUN` YEAR
)
BEGIN
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL33;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL33 ENGINE=MEMORY
	
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl33.JUMLAH IS NULL,0,rl33.JUMLAH)) JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT tindk.RL33,COUNT(tm.TINDAKAN) JUMLAH
  				 FROM layanan.tindakan_medis tm
  				 	 , master.rl33_tindakan tindk 
				 WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				  GROUP BY tindk.RL33) rl33 ON rl33.RL33=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=3
		GROUP BY rl.ID
		ORDER BY rl.ID;

	INSERT INTO `kemkes-sirs`.`rl3-3` (tahun, `no`, jenis_kegiatan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI, IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL33 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-3` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-3` r, TEMP_LAPORAN_RL33 t
	  SET r.jumlah = IFNULL(t.JUMLAH, 0)
	WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk trigger kemkes-sirs.rl3-3_before_update
DROP TRIGGER IF EXISTS `rl3-3_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-3_before_update` BEFORE UPDATE ON `rl3-3` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
