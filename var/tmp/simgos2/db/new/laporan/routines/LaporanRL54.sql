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

-- membuang struktur untuk procedure laporan.LaporanRL54
DROP PROCEDURE IF EXISTS `LaporanRL54`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL54`(
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
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2)
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
