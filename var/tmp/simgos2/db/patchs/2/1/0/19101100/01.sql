-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.26 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk laporan
#CREATE DATABASE IF NOT EXISTS `laporan` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanRL2
DROP PROCEDURE IF EXISTS `LaporanRL2`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL2`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.KODE, rl.DESKRIPSI, ''',TAHUN,''' TAHUN, SUM(IF(PRIA IS NULL,0,PRIA)) PRIA, SUM(IF(WANITA IS NULL,0,WANITA)) WANITA
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT refrl.KODE_HIRARKI, rl2.RL2, SUM(IF(p.JENIS_KELAMIN=1,1,0)) PRIA, SUM(IF(p.JENIS_KELAMIN=2,1,0)) WANITA
								FROM master.pegawai p
									, master.rl2_pegawai rl2
									, master.refrl refrl
								WHERE p.NIP=rl2.NIP AND rl2.RL2=refrl.ID AND refrl.JENISRL=''100102'' AND refrl.IDJENISRL=1
								GROUP BY rl2.RL2) rl2 ON rl2.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100102'' AND jrl.ID=1
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
