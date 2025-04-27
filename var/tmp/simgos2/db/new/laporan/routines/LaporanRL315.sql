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

-- membuang struktur untuk procedure laporan.LaporanRL315
DROP PROCEDURE IF EXISTS `LaporanRL315`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL315`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME

)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.KODE, rl.DESKRIPSI, ''',TAHUN,''' TAHUN
				, SUM(IF(rl315.JMLRJ IS NULL,0, rl315.JMLRJ)) RJ
				, SUM(IF(rl315.JMLLAB IS NULL,0, rl315.JMLLAB)) LAB
				, SUM(IF(rl315.JMLRAD IS NULL,0, rl315.JMLRAD)) RAD
				, SUM(IF(rl315.JMLRI IS NULL,0, rl315.JMLRI)) JMLRI
				, SUM(IF(rl315.LD IS NULL,0, rl315.LD)) LD
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
		/* Pasien Pengunjung RJ */
			LEFT JOIN (SELECT penjamin.RL315, refrl.KODE_HIRARKI ,COUNT(pd.NOMOR) JMLRJ, 0 JMLLAB, 0 JMLRAD, 0 JMLRI, 0 LD
							FROM pendaftaran.pendaftaran pd
								  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
								  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
								   LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
								   LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL=''100103'' AND refrl.IDJENISRL=16
								, pendaftaran.tujuan_pasien tp
								  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
								, pendaftaran.kunjungan tk
								, master.ruangan jkr
							WHERE pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN
									AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
									AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND jkr.JENIS_KUNJUNGAN=1 
							GROUP BY penjamin.RL315
							UNION
			/* Pasien RJ Laboratorium dan RJ Radiologi */
							SELECT penjamin.RL315, refrl.KODE_HIRARKI ,0 JMLRJ, SUM(IF(jkr.JENIS_KUNJUNGAN=4 AND (tk.REF IS NULL OR lab.JENIS_KUNJUNGAN=1),1,0)) JMLLAB,
							       SUM(IF(jkr.JENIS_KUNJUNGAN=5 AND (tk.REF IS NULL OR rad.JENIS_KUNJUNGAN=1),1,0)) JMLRAD, 0 JMLRI, 0 LD
							FROM pendaftaran.pendaftaran pd
								  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
								  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
								   LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
								   LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL=''100103'' AND refrl.IDJENISRL=16
								, pendaftaran.tujuan_pasien tp
								  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
								, pendaftaran.kunjungan tk
								  LEFT JOIN layanan.order_lab ol ON tk.REF=ol.NOMOR
								  LEFT JOIN pendaftaran.kunjungan kjol ON kjol.NOMOR=ol.KUNJUNGAN
								  LEFT JOIN master.ruangan lab ON kjol.RUANGAN=lab.ID AND lab.JENIS_KUNJUNGAN=1
								  LEFT JOIN layanan.order_rad orad ON tk.REF=orad.NOMOR
								  LEFT JOIN pendaftaran.kunjungan kjorad ON kjorad.NOMOR=orad.KUNJUNGAN
								  LEFT JOIN master.ruangan rad ON kjorad.RUANGAN=rad.ID AND rad.JENIS_KUNJUNGAN=1
								, master.ruangan jkr
							WHERE pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN
									AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
									AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND jkr.JENIS_KUNJUNGAN IN (4 ,5)
							GROUP BY penjamin.RL315
			/*	Pasien Keluar dan Lama Dirawat */
							UNION
							SELECT penjamin.RL315, refrl.KODE_HIRARKI ,0 JMLRJ, 0 JMLLAB, 0 JMLRAD, COUNT(lpp.KUNJUNGAN) JMLRI, SUM(DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LD
							FROM pendaftaran.pendaftaran pd
								  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
								  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
								   LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
								   LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL=''100103'' AND refrl.IDJENISRL=16
								, pendaftaran.kunjungan tk
								, master.ruangan jkr
								, layanan.pasien_pulang lpp
							WHERE  pd.NOMOR=tk.NOPEN AND lpp.KUNJUNGAN=tk.NOMOR AND lpp.`STATUS`=1 
									AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
									AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									AND jkr.JENIS_KUNJUNGAN=3 
							GROUP BY penjamin.RL315) rl315 ON rl315.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
			
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=16
		GROUP BY rl.ID
		ORDER BY rl.ID ');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
