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

-- membuang struktur untuk procedure laporan.LaporanRL312
DROP PROCEDURE IF EXISTS `LaporanRL312`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL312`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	 DECLARE TAHUN INT;
      
    SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	 
	 SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.ID, rl.KODE, rl.DESKRIPSI, NONRUJUKAN, RJ, RI, KUNJUNGANULANG
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT tindk.RL312
							, SUM(IF((SELECT r.JENIS_KUNJUNGAN 
										FROM pendaftaran.konsul k 
											, pendaftaran.kunjungan kjgn
											  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
										WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
										LIMIT 1) NOT IN (1,3) AND pk.REF IS NULL AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) NONRUJUKAN
							, SUM(IF((SELECT r.JENIS_KUNJUNGAN 
										FROM pendaftaran.konsul k 
											, pendaftaran.kunjungan kjgn
											  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
										WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
										LIMIT 1)=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) RJ
										, SUM(IF((SELECT r.JENIS_KUNJUNGAN 
										FROM pendaftaran.konsul k 
											, pendaftaran.kunjungan kjgn
											  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
										WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
										LIMIT 1)=3 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) RI
							, SUM(IF(DATE(pp.TANGGAL)!=DATE(p.TANGGAL_LAHIR),1,0)) KUNJUNGANULANG
						 FROM layanan.tindakan_medis tm
						 	 , master.rl312_tindakan tindk 
						 	 , pendaftaran.kunjungan pk
						 	 , pendaftaran.pendaftaran pp
						 	 , master.pasien p
						 WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						 	AND tm.STATUS!=0 AND tm.TINDAKAN=tindk.ID AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
						 	AND pk.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pp.NORM=p.NORM
						  GROUP BY tindk.RL312) rl312 ON rl312.RL312=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=12
		  ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
