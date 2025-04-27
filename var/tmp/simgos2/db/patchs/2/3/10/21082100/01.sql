-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE laporan;
-- Dumping structure for procedure laporan.LaporanPasienMeninggal
DROP PROCEDURE IF EXISTS `LaporanPasienMeninggal`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienMeninggal`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN PASIEN MENINGGAL '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 INSERT(INSERT(LPAD(ps.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR, crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pp.TANGGAL TGLMASUK, lpp.TANGGAL TGLKELUAR, lpm.TANGGAL TGLMENINGGAL ,cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR,
		    r.DESKRIPSI UNIT
	FROM layanan.pasien_pulang lpp
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  layanan.pasien_meninggal lpm,
		  pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN master.referensi rjk ON ps.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1 ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
	   AND lpp.KUNJUNGAN=lpm.KUNJUNGAN AND lpm.STATUS=1
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR AND lpm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		GROUP BY lpp.NOPEN
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
