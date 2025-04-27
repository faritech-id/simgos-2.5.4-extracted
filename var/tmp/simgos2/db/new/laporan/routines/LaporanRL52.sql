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

-- membuang struktur untuk procedure laporan.LaporanRL52
DROP PROCEDURE IF EXISTS `LaporanRL52`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL52`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME



)
BEGIN	
	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*,rl.KODE, rl.DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, b.*
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT rl.RL52, COUNT(pd.NOMOR) JUMLAH
			  					   , SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKI
			  					   , SUM(IF(p.JENIS_KELAMIN!=1,1,0)) PR
								FROM master.pasien p
									, pendaftaran.pendaftaran pd
									  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
									  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
									  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
									  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
									 # LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
									#  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
									  
									, pendaftaran.kunjungan tk
									, master.ruangan jkr
									, pendaftaran.tujuan_pasien tps
									, master.rl52_ruangan rl
								WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=1
										AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
										AND pd.NOMOR=tps.NOPEN AND tk.RUANGAN=rl.ID
								GROUP BY rl.RL52
								UNION
								SELECT 24 RL52, COUNT(pd.NOMOR) JUMLAH
										, SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKI
			  					      , SUM(IF(p.JENIS_KELAMIN!=1,1,0)) PR
									FROM master.pasien p
										, pendaftaran.pendaftaran pd
										  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
										  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
										  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
										  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
									#	  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
									#	  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
									    
										, pendaftaran.kunjungan tk
										, master.ruangan jkr
									#	, pendaftaran.tujuan_pasien tps
									WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=2
											AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)) b ON b.RL52=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100105'' AND jrl.ID=2 AND rl.KODE!=''99''
		ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
