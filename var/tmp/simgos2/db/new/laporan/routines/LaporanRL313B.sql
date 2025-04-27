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

-- membuang struktur untuk procedure laporan.LaporanRL313B
DROP PROCEDURE IF EXISTS `LaporanRL313B`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL313B`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	
		DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI
			  , SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
								FROM (
								SELECT 1 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
											FROM (
												SELECT DISTINCT(o.NOMOR) JML
														, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
														, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
														, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
													FROM layanan.order_resep o
														, layanan.order_detil_resep od
														, pendaftaran.kunjungan pk
														, master.ruangan r
														, inventory.barang ib
													WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
														AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
														AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=1
													GROUP BY o.NOMOR) ab
									UNION
									SELECT 2 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
											FROM (
												SELECT DISTINCT(o.NOMOR) JML
														, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
														, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
														, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
													FROM layanan.order_resep o
														, layanan.order_detil_resep od
														, pendaftaran.kunjungan pk
														, master.ruangan r
														, inventory.barang ib
													WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
														AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
														AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=1
													GROUP BY o.NOMOR) ab
									UNION
									SELECT 3 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
											FROM (
												SELECT DISTINCT(o.NOMOR) JML
														, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
														, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
														, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
													FROM layanan.order_resep o
														, layanan.order_detil_resep od
														, pendaftaran.kunjungan pk
														, master.ruangan r
														, inventory.barang ib
													WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
														AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
														AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=2
													GROUP BY o.NOMOR) ab
									
									) ac
									GROUP BY ID
									) rl313b ON rl.ID=rl313b.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=13
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
