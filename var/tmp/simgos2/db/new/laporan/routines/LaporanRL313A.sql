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

-- membuang struktur untuk procedure laporan.LaporanRL313A
DROP PROCEDURE IF EXISTS `LaporanRL313A`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL313A`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME
)
BEGIN	

	
		DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI, SUM(JUMLAH) JUMLAH
			  , SUM(TERSEDIA) TERSEDIA, SUM(FORNAS) FORNAS
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT ID, SUM(JUMLAH) JUMLAH, SUM(TERSEDIA) TERSEDIA
								, IF(ID=1,SUM(FORNAS),IF(ID=2,SUM(TERSEDIA),0)) FORNAS
								FROM (
							SELECT 1 ID, COUNT(ib.ID) JUMLAH
										, (SELECT COUNT(JML)  
											FROM (
												SELECT DISTINCT(br.ID) JML
														FROM inventory.barang_ruangan br
															, inventory.barang ib
															, inventory.transaksi_stok_ruangan tsr
														WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID
														  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=1 AND tsr.STOK > 0
														  AND tsr.TANGGAL < ''',TGLAKHIR,'''
														GROUP BY br.BARANG) ab) TERSEDIA
											, (SELECT COUNT(JML)  
													FROM (
														SELECT DISTINCT(br.ID) JML
														FROM inventory.barang_ruangan br
															, inventory.barang ib
															, inventory.transaksi_stok_ruangan tsr
														WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=1
														  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=1 AND tsr.STOK > 0
														  AND tsr.TANGGAL < ''',TGLAKHIR,'''
														GROUP BY br.BARANG) ab) FORNAS
									FROM inventory.barang ib
									WHERE ib.JENIS_GENERIK=1
									UNION
									SELECT 2 ID, COUNT(ib.ID) JUMLAH
										, (SELECT COUNT(JML)  
											FROM (
												SELECT DISTINCT(br.ID) JML
														FROM inventory.barang_ruangan br
															, inventory.barang ib
															, inventory.transaksi_stok_ruangan tsr
														WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=1
														  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=2 AND tsr.STOK > 0
														  AND tsr.TANGGAL < ''',TGLAKHIR,'''
														GROUP BY br.BARANG) ab) TERSEDIA
											, 0 FORNAS
									FROM inventory.barang ib
									WHERE ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=1
									UNION
									SELECT 3 ID, COUNT(ib.ID) JUMLAH
										, (SELECT COUNT(JML)  
											FROM (
												SELECT DISTINCT(br.ID) JML
														FROM inventory.barang_ruangan br
															, inventory.barang ib
															, inventory.transaksi_stok_ruangan tsr
														WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=2
														  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=2 AND tsr.STOK > 0
														  AND tsr.TANGGAL < ''',TGLAKHIR,'''
														GROUP BY br.BARANG) ab) TERSEDIA
											, 0 FORNAS
									FROM inventory.barang ib
									WHERE ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=2) ab
								GROUP BY ID) rl313a ON rl.ID=rl313a.ID
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
