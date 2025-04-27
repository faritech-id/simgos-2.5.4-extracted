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

-- membuang struktur untuk procedure laporan.LaporanKunjunganPerHari
DROP PROCEDURE IF EXISTS `LaporanKunjunganPerHari`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanKunjunganPerHari`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	
	DECLARE vTanggalAwal DATE;
   DECLARE vTanggalAkhir DATE;
   DECLARE vRUANGAN VARCHAR(11);
      
   SET vTanggalAwal = DATE_FORMAT(TGLAWAL,'%Y-%m-%d');
   SET vTanggalAkhir = DATE_FORMAT(TGLAKHIR,'%Y-%m-%d');
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT tgl.*, a.*, INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN KUNJUNGAN '',UPPER(jk.DESKRIPSI),'' PER HARI'') JENISLAPORAN
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		FROM master.tanggal tgl
			  LEFT JOIN (
								SELECT DATE(tk.MASUK) TANGGAL 
										, COUNT(pd.NOMOR) JUMLAH
										, SUM(IF(tk.BARU=1,1,0)) BARU
										, SUM(IF(tk.BARU=0,1,0)) LAMA
										, SUM(IF(ref.ID=1,1,0)) UMUM
										, SUM(IF(ref.ID=2,1,0)) JKN
										, SUM(IF(ref.ID=3,0,0)) INHEALTH
										, SUM(IF(ref.ID=4,0,0)) JKD
										, SUM(IF(iks.ID IS NOT NULL,1,0)) IKS
										, SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKILAKI
										, SUM(IF(p.JENIS_KELAMIN=2,1,0)) PEREMPUAN
									FROM master.pasien p
										, pendaftaran.pendaftaran pd
										  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
										  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
										  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
										  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
										  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
										  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
										, pendaftaran.kunjungan tk
										, master.ruangan jkr
									WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=',LAPORAN,'
											AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
											AND tk.RUANGAN LIKE ''',vRUANGAN,'''
											',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
									GROUP BY DATE(tk.MASUK) ) a ON a.TANGGAL=tgl.TANGGAL
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
			  , (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			  
		WHERE tgl.TANGGAL BETWEEN ''',vTanggalAwal,''' AND ''',vTanggalAkhir,'''
	GROUP BY tgl.TANGGAL');


	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
