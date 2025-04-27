-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for laporan
CREATE DATABASE IF NOT EXISTS `laporan`;
USE `laporan`;

-- Dumping structure for procedure laporan.LaporanPasienPerICD10
DROP PROCEDURE IF EXISTS `LaporanPasienPerICD10`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienPerICD10`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KODEICD` CHAR(6),
	IN `UTAMA` CHAR(50),
	IN `LMT` SMALLINT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN ICD 10 '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 INSERT(INSERT(LPAD(ps.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP,
			 CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR, crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pp.TANGGAL TGLMASUK, lpp.TANGGAL TGLKELUAR, cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR,
		    r.DESKRIPSI UNIT, md.KODE KODEICD10,
			 GROUP_CONCAT((SELECT CONCAT(ms.CODE,''['',ms.STR,'']'') FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1)) DIAGNOSA,
			 IF(''',KODEICD,'''='''' OR ''',KODEICD,'''=''0'' ,''Semua'',(SELECT CONCAT(ms.CODE,''-'',ms.STR) FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1)) DIAGNOSAHEADER
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
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	   AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='' OR KODEICD='0','',CONCAT(' AND md.KODE=''',KODEICD,'''')),'
		',IF(UTAMA=0,'',CONCAT(' AND md.UTAMA=1')),'
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
	GROUP BY md.NOPEN
	',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),'
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienPerICD9CM
DROP PROCEDURE IF EXISTS `LaporanPasienPerICD9CM`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienPerICD9CM`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KODEICD` CHAR(6),
	IN `UTAMA` INT,
	IN `LMT` TINYINT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN ICD 9 CM '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 INSERT(INSERT(LPAD(ps.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, 
			 CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR,crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR,IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pp.TANGGAL TGLMASUK, lpp.TANGGAL TGLKELUAR, cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR,
		    r.DESKRIPSI UNIT, mps.KODE KODEICD9CM,
			 GROUP_CONCAT((SELECT CONCAT(ms.CODE,''['',ms.STR,'']'') FROM master.mrconso ms WHERE ms.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=mps.KODE LIMIT 1)) PROSEDUR,
			 IF(''',KODEICD,'''='''' OR ''',KODEICD,'''=''0'',''Semua'',(SELECT CONCAT(ms.CODE,''-'',ms.STR) FROM master.mrconso ms WHERE ms.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=mps.KODE LIMIT 1)) PROSEDURHEADER
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
		  medicalrecord.prosedur mps,
		  pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=mps.NOPEN AND mps.STATUS=1 AND mps.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	   AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='' OR KODEICD='0','',CONCAT(' AND mps.KODE=',KODEICD)),'
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
	GROUP BY mps.NOPEN
	',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),'
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRekapPerICD10
DROP PROCEDURE IF EXISTS `LaporanRekapPerICD10`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapPerICD10`(
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
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
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
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
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

-- Dumping structure for procedure laporan.LaporanRekapPerICD10Kecamatan
DROP PROCEDURE IF EXISTS `LaporanRekapPerICD10Kecamatan`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapPerICD10Kecamatan`(
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
		  LEFT JOIN layanan.pasien_pulang lpp ON lpp.NOPEN=pk.NOPEN AND lpp.`STATUS`=1
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
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
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
 SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN REKAP PER ICD 10 ('',UPPER(jk.DESKRIPSI),'')'') JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 md.KODE KODEICD10,
			 (SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
			  IF(LEFT(INST.KODERS,4)=LEFT(ps.WILAYAH,4),ps.WILAYAH,''9999999999'') WILAYAH, 
			  IF(LEFT(INST.KODERS,4)=LEFT(ps.WILAYAH,4),IF(w.DESKRIPSI IS NULL, ''DLL'', w.DESKRIPSI),''ZLUAR KOTA'') DESKRIPSI,
			  COUNT(md.KODE) JUMLAH, 
			  @ROWS TOTAL
	FROM pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		 LEFT JOIN layanan.pasien_pulang lpp ON lpp.NOPEN=pk.NOPEN AND lpp.`STATUS`=1
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		  LEFT JOIN master.wilayah w ON LEFT(ps.WILAYAH,6)=LEFT(w.ID,6) AND w.JENIS=3,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  medicalrecord.diagnosa md,
		  pendaftaran.tujuan_pasien tp,
		  (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST,
		(SELECT  KODEICD10, JUMLAH  FROM (
			SELECT md.KODE KODEICD10,
					  COUNT(md.KODE) JUMLAH
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
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
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
			',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),') kdicd
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	  AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(UTAMA=0,'',CONCAT(' AND md.UTAMA=1')),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='' OR KODEICD='0','',CONCAT(' AND md.KODE=',KODEICD)),' 
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
		AND LEFT(md.KODE,1) NOT IN (''Z'',''O'','''',''R'',''V'',''W'',''Y'')
		AND md.KODE=kdicd.KODEICD10
	GROUP BY md.KODE, ps.WILAYAH
	ORDER BY kdicd.JUMLAH DESC
	');
	   
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRekapPerICD9CM
DROP PROCEDURE IF EXISTS `LaporanRekapPerICD9CM`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapPerICD9CM`(
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
	SELECT COUNT(mps.KODE) INTO @ROWS
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
		  medicalrecord.prosedur mps,
		   pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=mps.NOPEN AND mps.STATUS=1 AND mps.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
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
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN REKAP PER ICD 9 CM ('',UPPER(jk.DESKRIPSI),'')'') JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 mps.KODE KODEICD9CM,
			 (SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=mps.KODE LIMIT 1) PROSEDUR, COUNT(mps.KODE) JUMLAH, @ROWS TOTAL
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
		  medicalrecord.prosedur mps,
		  pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=mps.NOPEN AND mps.STATUS=1 AND mps.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	   AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='' OR KODEICD='0','',CONCAT(' AND mps.KODE=',KODEICD)),' 
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
	GROUP BY mps.KODE) c
	ORDER BY JUMLAH DESC
	',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),'
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL34
DROP PROCEDURE IF EXISTS `LaporanRL34`;
DELIMITER //
CREATE PROCEDURE `LaporanRL34`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI, JUMLAH, RS, BIDAN, PUSKESMAS, FASKES, RUJUKANHIDUP, RUJUKANMATI,NONMEDISHIDUP
			, NONMEDISMATI, NONRUJUKANHIDUP, NONRUJUKANMATI, DIRUJUK
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT ic.RL34 ID, COUNT(md.NOPEN) JUMLAH
							, SUM(IF(pr.JENIS=1,1,0)) RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2,1,0)) PUSKESMAS
							, SUM(IF(pr.JENIS NOT IN (1,2),1,0)) FASKES
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) RUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
							, 0 NONMEDISHIDUP, 0 NONMEDISMATI
							, SUM(IF(pp.RUJUKAN IS NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) NONRUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
							, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
						FROM medicalrecord.diagnosa md
							, master.rl34_icd10 ic
							, pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
						WHERE md.`STATUS`!=0 AND md.KODE=ic.ID AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND md.NOPEN=pp.NOMOR AND md.INA_GROUPER=0 AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
						GROUP BY ic.RL34) rl34 ON rl34.ID=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=4
		ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL35
DROP PROCEDURE IF EXISTS `LaporanRL35`;
DELIMITER //
CREATE PROCEDURE `LaporanRL35`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN,rl.ID, rl.KODE, rl.DESKRIPSI, JUMLAH
			, IF(rl.ID >= 4,0,SUM(RS)) RS, IF(rl.ID >= 4,0,SUM(BIDAN)) BIDAN, IF(rl.ID >= 4,0,SUM(PUSKESMAS)) PUSKESMAS
			, IF(rl.ID >= 4,0,SUM(FASKES)) FASKES
			, IF(rl.ID >= 4,0,SUM(RUJUKANHIDUP)) RUJUKANHIDUP
			, IF(rl.ID < 4,0,SUM(RUJUKANMATI)) RUJUKANMATI
			, IF(rl.ID >= 4,0,SUM(NONMEDISHIDUP)) NONMEDISHIDUP
			, IF(rl.ID < 4,0,SUM(NONMEDISMATI)) NONMEDISMATI
			, IF(rl.ID >= 4,0,SUM(NONRUJUKANHIDUP)) NONRUJUKANHIDUP
			, IF(rl.ID < 4,0,SUM(NONRUJUKANMATI)) NONRUJUKANMATI
			, IF(rl.ID >= 4,0,SUM(DIRUJUK)) DIRUJUK
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT 2 ID, COUNT(pp.NOMOR) JUMLAH
							, SUM(IF(pr.JENIS=1 AND pl.CARA NOT IN (6,7),1,0)) RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2 AND pl.CARA NOT IN (6,7),1,0)) PUSKESMAS
							, SUM(IF(pr.JENIS NOT IN (1,2) AND pl.CARA NOT IN (6,7),1,0)) FASKES
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA NOT IN (6,7),1,0)) RUJUKANHIDUP
							, 0 RUJUKANMATI
							, 0 NONMEDISHIDUP
							, 0 NONMEDISMATI
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA NOT IN (6,7),1,0)) NONRUJUKANHIDUP
							, 0 NONRUJUKANMATI
							, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
						FROM pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						WHERE pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
						  AND pp.BERAT_BAYI >= 2500
						GROUP BY ID
					   UNION
					   SELECT 3 ID, COUNT(pp.NOMOR) JUMLAH
							, SUM(IF(pr.JENIS=1 AND pl.CARA NOT IN (6,7),1,0)) RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2 AND pl.CARA NOT IN (6,7),1,0)) PUSKESMAS
							, SUM(IF(pr.JENIS NOT IN (1,2) AND pl.CARA NOT IN (6,7),1,0)) FASKES
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA NOT IN (6,7),1,0)) RUJUKANHIDUP
							, 0 RUJUKANMATI
							, 0 NONMEDISHIDUP
							, 0 NONMEDISMATI
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA NOT IN (6,7),1,0)) NONRUJUKANHIDUP
							, 0 NONRUJUKANMATI
							, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
						FROM pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						WHERE pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
						  AND pp.BERAT_BAYI < 2500
						GROUP BY ID
						UNION
						SELECT 5 ID, COUNT(md.NOPEN) JUMLAH
							, 0 RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2 AND pl.CARA IN (6,7),1,0)) PUSKESMAS
							, 0 FASKES
							, 0 RUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
							, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
							, 0 DIRUJUK
						FROM medicalrecord.diagnosa md
							, pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						WHERE md.`STATUS`!=0  AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND md.NOPEN=pp.NOMOR AND md.INA_GROUPER=0 AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
						  AND md.KODE=''P95''
						GROUP BY ID
						UNION
						SELECT 6 ID, COUNT(md.NOPEN) JUMLAH
							, 0 RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2 AND pl.CARA IN (6,7),1,0)) PUSKESMAS
							, 0 FASKES
							, 0 RUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
							, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
							, 0 DIRUJUK
						FROM medicalrecord.diagnosa md
							, medicalrecord.diagnosa_meninggal mdm
							, pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						WHERE md.`STATUS`!=0  AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND md.NOPEN=pp.NOMOR AND md.INA_GROUPER=0 AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
						  AND md.NOPEN=mdm.NOPEN AND mdm.UTAMA=1 AND DATEDIFF(pl.TANGGAL,pp.TANGGAL) < 7
						GROUP BY ID
						UNION
						SELECT ic.RL35 ID, COUNT(md.NOPEN) JUMLAH
							, 0 RS
							, 0 BIDAN
							, 0 PUSKESMAS
							, 0 FASKES, 0 RUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
							, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
							, 0 DIRUJUK
						FROM medicalrecord.diagnosa md
							, medicalrecord.diagnosa_meninggal mdm
							, master.rl35_icd10 ic
							, pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						WHERE md.`STATUS`!=0 AND md.INA_GROUPER=0 AND mdm.KODE=ic.ID AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
						  AND ic.RL35 > 6 AND md.NOPEN=mdm.NOPEN AND mdm.UTAMA=1
						GROUP BY ic.RL35) rl35 ON rl35.ID=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=5
		GROUP BY rl.ID
		ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL4A
DROP PROCEDURE IF EXISTS `LaporanRL4A`;
DELIMITER //
CREATE PROCEDURE `LaporanRL4A`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.ID, rl.KODE, rl.NODAFTAR, rl.DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, b.*
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, 
					 SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI, 
					 SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA, 
					 SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3 AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100104'' AND jrl.ID=1
		  ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL4ASebab
DROP PROCEDURE IF EXISTS `LaporanRL4ASebab`;
DELIMITER //
CREATE PROCEDURE `LaporanRL4ASebab`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.ID, rl.KODE, rl.NODAFTAR, rl.DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, b.*
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI, SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA, SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3 AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100104'' AND jrl.ID=2
		ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL4B
DROP PROCEDURE IF EXISTS `LaporanRL4B`;
DELIMITER //
CREATE PROCEDURE `LaporanRL4B`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.ID, rl.KODE, rl.NODAFTAR, rl.DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, b.*
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100104'' AND jrl.ID=3
		ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL4BSebab
DROP PROCEDURE IF EXISTS `LaporanRL4BSebab`;
DELIMITER //
CREATE PROCEDURE `LaporanRL4BSebab`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	

	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.ID, rl.KODE, rl.NODAFTAR, rl.DESKRIPSI, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, b.*
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100104'' AND jrl.ID=4
		ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL53
DROP PROCEDURE IF EXISTS `LaporanRL53`;
DELIMITER //
CREATE PROCEDURE `LaporanRL53`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	
	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
	 SELECT * FROM (
			SELECT INST.*, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, md.KODE KODEICD10,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND lpp.CARA NOT IN (6,7),1,0)) LAKIHIDUP, SUM(IF(ps.JENIS_KELAMIN=2 AND lpp.CARA NOT IN (6,7),1,0)) WANITAHIDUP,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND lpp.CARA IN (6,7),1,0)) LAKIMATI, SUM(IF(ps.JENIS_KELAMIN=2 AND lpp.CARA IN (6,7),1,0)) WANITAMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI, 
					 SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA, 
					 SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
								FROM aplikasi.instansi ai
									, master.ppk p
									, master.wilayah w
								WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3
				AND pk.NOPEN=pp.NOMOR AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND LEFT(md.KODE,1) NOT IN (''Z'',''O'','''',''R'',''V'',''W'',''Y'')
			GROUP BY md.KODE) c
			
		ORDER BY JUMLAH DESC
		LIMIT 10
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;


END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL54
DROP PROCEDURE IF EXISTS `LaporanRL54`;
DELIMITER //
CREATE PROCEDURE `LaporanRL54`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN	
	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
	 SELECT * FROM (
			SELECT INST.*, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, md.KODE KODEICD10,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
								FROM aplikasi.instansi ai
									, master.ppk p
									, master.wilayah w
								WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2)
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND LEFT(md.KODE,1) NOT IN (''Z'',''O'','''',''R'',''V'',''W'',''Y'')
			GROUP BY md.KODE) c
		ORDER BY JUMLAH DESC
		LIMIT 10
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
