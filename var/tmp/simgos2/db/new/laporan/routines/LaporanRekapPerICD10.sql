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

-- membuang struktur untuk procedure laporan.LaporanRekapPerICD10
DROP PROCEDURE IF EXISTS `LaporanRekapPerICD10`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRekapPerICD10`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KODEICD` CHAR(6),
	IN `UTAMA` TINYINT,
	IN `LMT` SMALLINT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
 
 SET @sqlText = CONCAT('
	SELECT COUNT(md.KODE) INTO @ROWS
	FROM pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN pendaftaran.kunjungan pk2 ON pk.NOPEN=pk2.NOPEN AND pk2.`STATUS` IN (1,2)
		  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk2.NOMOR AND lpp.`STATUS`=1
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  medicalrecord.diagnosa md,
		   pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	   AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR 
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
	
	');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
		 
 SET @sqlText = CONCAT('
 SELECT * FROM (
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN REKAP PER ICD 10 ('',UPPER(jk.DESKRIPSI),'')'') JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 md.KODE KODEICD10,
			 (SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, COUNT(md.KODE) JUMLAH, 
			 SUM(IF(ps.JENIS_KELAMIN=1,1,0)) PRIA, SUM(IF(ps.JENIS_KELAMIN=2,1,0)) WANITA,
			 SUM(IF(master.getKelompokUmurICDTerbanyak(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) BAYI,
			 SUM(IF(master.getKelompokUmurICDTerbanyak(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) ANAK,
			 SUM(IF(master.getKelompokUmurICDTerbanyak(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) DEWASA,
			 SUM(IF(master.getKelompokUmurICDTerbanyak(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) LANSIA,
			 @ROWS TOTAL
	FROM pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN pendaftaran.kunjungan pk2 ON pk.NOPEN=pk2.NOPEN AND pk2.`STATUS` IN (1,2)
		  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk2.NOMOR AND lpp.`STATUS`=1
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  medicalrecord.diagnosa md,
		  pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	  AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(UTAMA=0,'',CONCAT(' AND md.UTAMA=1')),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='' OR KODEICD='0','',CONCAT(' AND md.KODE=',KODEICD)),' 
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
		AND LEFT(md.KODE,1) NOT IN (''Z'',''O'','''',''R'',''V'',''W'',''Y'')
	GROUP BY md.KODE) c
	ORDER BY JUMLAH DESC
	',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),'
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
