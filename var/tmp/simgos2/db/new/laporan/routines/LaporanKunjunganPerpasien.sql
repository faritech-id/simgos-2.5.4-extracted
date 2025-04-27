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

-- membuang struktur untuk procedure laporan.LaporanKunjunganPerpasien
DROP PROCEDURE IF EXISTS `LaporanKunjunganPerpasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanKunjunganPerpasien`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT)
BEGIN

	
	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   
	SET @sqlText = CONCAT('
	SELECT CONCAT(''LAPORAN KUNJUNGAN '',UPPER(jk.DESKRIPSI),'' PER PASIEN'') JENISLAPORAN, INSERT(INSERT(LPAD(p.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,TANGGAL_LAHIR),'')'') TGL_LAHIR
		, rjk.DESKRIPSI JENISKELAMIN
		, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
		, ref.DESKRIPSI CARABAYAR
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, su.DESKRIPSI UNITPELAYANAN
		, INST.NAMAINST, INST.ALAMATINST
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
	FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
		, pendaftaran.kunjungan tk
		, master.ruangan jkr
		  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
			FROM aplikasi.instansi ai
				, master.ppk p
			WHERE ai.PPK=p.ID) INST
		, (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=',LAPORAN,'
			AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
			AND tk.RUANGAN LIKE ''',vRUANGAN,'''
			',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
