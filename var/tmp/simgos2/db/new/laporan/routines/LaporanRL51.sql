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

-- membuang struktur untuk procedure laporan.LaporanRL51
DROP PROCEDURE IF EXISTS `LaporanRL51`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL51`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME)
BEGIN	
	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
	SET @sqlText = CONCAT('
		SELECT INST.*,a.*, ref.ID, CONCAT(''Pengunjung '',ref.DESKRIPSI) DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN
			FROM master.referensi ref
				  LEFT JOIN (
									SELECT IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),1,2) IDSTATUSPENGUNJUNG
											, COUNT(pd.NOMOR) JUMLAH
									FROM master.pasien p
											, pendaftaran.pendaftaran pd
											, pendaftaran.tujuan_pasien tp
											  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
											, pendaftaran.kunjungan tk
									WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2)
												AND tk.RUANGAN=r.ID AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
												AND r.JENIS_KUNJUNGAN=1
									GROUP BY IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),1,2) ) a ON a.IDSTATUSPENGUNJUNG=ref.ID
				, (SELECT p.KODE, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
			  , (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=1 AND jk.JENIS=15) jk
			WHERE ref.JENIS=22
			GROUP BY ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
