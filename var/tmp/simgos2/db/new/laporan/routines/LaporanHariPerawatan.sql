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

-- membuang struktur untuk procedure laporan.LaporanHariPerawatan
DROP PROCEDURE IF EXISTS `LaporanHariPerawatan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanHariPerawatan`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `CARAKELUAR` TINYINT, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT)
BEGIN
  DECLARE vTGLAWAL DATE;
  DECLARE vTGLAKHIR DATE;
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');     
  SET vTGLAWAL = DATE(TGLAWAL);
  SET vTGLAKHIR = DATE(TGLAKHIR);
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN HARI PERAWATAN '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 INSERT(INSERT(LPAD(ps.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, ps.TANGGAL_LAHIR, crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pk.MASUK TGLMASUK, pk.KELUAR TGLKELUAR ,r.DESKRIPSI UNIT, CONCAT(rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR,COUNT(pk.NOMOR) JMLHP
	FROM pendaftaran.kunjungan pk
		 	 LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		    LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
		    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
		    LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		  , pendaftaran.pendaftaran pp
		    LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		    LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		  , (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
		  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
		  ,  (SELECT TANGGAL TGL
									  FROM master.tanggal 
									 WHERE TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''') bts
	WHERE pk.NOPEN=pp.NOMOR  ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),' AND pk.`STATUS` IN (1,2)
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
		AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
	GROUP BY pk.RUANGAN, pk.NOMOR
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
