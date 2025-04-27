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

-- membuang struktur untuk procedure laporan.LaporanRL32
DROP PROCEDURE IF EXISTS `LaporanRL32`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL32`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN
				, rl.KODE, rl.DESKRIPSI
				, RUJUKAN, NONRUJUKAN
				, ((RUJUKAN+NONRUJUKAN)-(DIRUJUK+PULANG+MENINGGAL+DOA)) DIRAWAT
				, DIRUJUK
				, PULANG
				, MENINGGAL
				, DOA
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT rl.RL32
			  						, SUM(IF(pp.RUJUKAN IS NOT NULL,1,0)) RUJUKAN
									, SUM(IF(pp.RUJUKAN IS NULL,1,0)) NONRUJUKAN
									, 0 DIRUJUK
									, 0 PULANG
									, 0 MENINGGAL
									, 0 DOA
								FROM pendaftaran.pendaftaran pp
									, pendaftaran.tujuan_pasien tp
									, master.ruangan r
									, master.rl32_smf rl
								WHERE pp.`STATUS` IN (1,2) AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN=2
								GROUP BY rl.RL32
								UNION
							SELECT rl.RL32
									, 0 RUJUKAN
									, 0 NONRUJUKAN
									, SUM(IF(pp.CARA=3,1,0)) DIRUJUK
									, SUM(IF(pp.CARA NOT IN (6,7),1,0)) PULANG
									, SUM(IF(pp.CARA=6,1,0)) MENINGGAL
									, SUM(IF(pp.CARA=7,1,0)) DOA
								FROM layanan.pasien_pulang pp
									, pendaftaran.kunjungan pk
									, pendaftaran.tujuan_pasien tp
									, master.ruangan r
									, master.rl32_smf rl
								WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.`STATUS` IN (1,2)
									AND pk.RUANGAN=rl.ID AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND pk.NOPEN=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN=2
								GROUP BY rl.RL32)b ON b.RL32=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=2
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
