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

-- membuang struktur untuk procedure laporan.LaporanRL314
DROP PROCEDURE IF EXISTS `LaporanRL314`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL314`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME


)
BEGIN	

	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI, SUM(PUSKESMAS) PUSKESMAS, SUM(FASKES) FASKES, SUM(RS) RS
				, SUM(KEMBALIPUSKESMAS) KEMBALIPUSKESMAS, SUM(KEMBALIFASKES) KEMBALIFASKES, SUM(KEMBALIRS) KEMBALIRS
				, SUM(PASIENRUJUKAN) PASIENRUJUKAN, SUM(DATANGSENDIRI) DATANGSENDIRI, SUM(DITERIMAKEMBALI) DITERIMAKEMBALI
		
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT rl.RL314
			  						, SUM(IF(pr.JENIS=2,1,0)) PUSKESMAS
			  						, SUM(IF(pr.JENIS NOT IN (1,2),1,0)) FASKES
									, SUM(IF(pr.JENIS=1,1,0)) RS
									, 0 KEMBALIPUSKESMAS
			  						, 0 KEMBALIFASKES
									, 0 KEMBALIRS
									, 0 PASIENRUJUKAN
									, 0 DATANGSENDIRI
									, 0 DITERIMAKEMBALI
								FROM pendaftaran.pendaftaran pp
								     LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							        LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							      , pendaftaran.tujuan_pasien tp
									, master.ruangan r
									, master.rl314_smf rl
								WHERE pp.`STATUS` IN (1,2) AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN IN (1,2)
								GROUP BY rl.RL314
								UNION
								SELECT rl.RL314
			  						, 0 PUSKESMAS
			  						, 0 FASKES
									, 0 RS
									, SUM(IF(prb.JENIS=2,1,0)) KEMBALIPUSKESMAS
			  						, SUM(IF(prb.JENIS NOT IN (1,2),1,0)) KEMBALIFASKES
									, SUM(IF(prb.JENIS=1,1,0)) KEMBALIRS
									, 0 PASIENRUJUKAN
									, 0 DATANGSENDIRI
									, 0 DITERIMAKEMBALI
								FROM pendaftaran.pendaftaran pp
								     LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							        LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							      , pendaftaran.rujukan_keluar rjk 
							        LEFT JOIN master.ppk prb ON rjk.TUJUAN=prb.KODE
									, pendaftaran.tujuan_pasien tp
									, master.ruangan r
									, master.rl314_smf rl
								WHERE pp.NOMOR=rjk.NOPEN AND rjk.STATUS!=0 AND pp.`STATUS` IN (1,2) AND rjk.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN
								GROUP BY rl.RL314) rl314 ON rl314.RL314=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=15
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
