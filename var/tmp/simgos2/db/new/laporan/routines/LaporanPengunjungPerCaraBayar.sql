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

-- membuang struktur untuk procedure laporan.LaporanPengunjungPerCaraBayar
DROP PROCEDURE IF EXISTS `LaporanPengunjungPerCaraBayar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPengunjungPerCaraBayar`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `LAPORAN` TINYINT, IN `CARABAYAR` SMALLINT)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Cara Bayar'')) JENISLAPORAN
				, ref.ID IDCARABAYAR
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, COUNT(pd.NOMOR) JUMLAH
				, SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKILAKI
				, SUM(IF(p.JENIS_KELAMIN=2,1,0)) PEREMPUAN
				, SUM(IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),1,0)) BARU
				, SUM(IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')!=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),1,0)) LAMA
				, INST.NAMAINST, INST.ALAMATINST
			FROM master.pasien p
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
				  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
				, pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				, pendaftaran.kunjungan tk
				, master.ruangan jkr
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
			  , (SELECT ID,DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
		
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
					AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
			GROUP BY ref.ID');
		

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
