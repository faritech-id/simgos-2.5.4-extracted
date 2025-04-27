-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanSurveilansRawatJalan
DROP PROCEDURE IF EXISTS `LaporanSurveilansRawatJalan`;
DELIMITER //
CREATE PROCEDURE `LaporanSurveilansRawatJalan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
    SQL SECURITY INVOKER
BEGIN	

	DECLARE BULAN VARCHAR(10);
   DECLARE TAHUN INT;
      
   SET BULAN = DATE_FORMAT(TGLAWAL,'%M');
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
   
   SET @sqlText = CONCAT('SELECT  COUNT(*) INTO @TOTALKASUS
   				FROM (
						SELECT md.KODE, ps.JENIS_KELAMIN, pp.TANGGAL,ps.TANGGAL_LAHIR, lpp.CARA
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
								  `master`.surveilans_penyakit_menular ic
							WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
								AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE_ICD10 AND md.BARU=1
								AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							GROUP BY pp.NORM
						) ab
					
			  ');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @sqlText = CONCAT('
		SELECT INST.*, rl.ID, rl.KODE_ICD10, rl.DESKRIPSI_PENYAKIT_MENULAR, ''',BULAN,''' BULAN, ''',TAHUN,''' TAHUN, 
				SUM(JUMLAH) JUMLAH, SUM(JMLLAKI) JMLLAKI, SUM(JMLWANITA) JMLWANITA, SUM(JMLMATI) JMLMATI,
				SUM(KLP1) KLP1, SUM(KLP2) KLP2, SUM(KLP3) KLP3, SUM(KLP4) KLP4, SUM(KLP5) KLP5, SUM(KLP6) KLP6,
				SUM(KLP7) KLP7, SUM(KLP8) KLP8, SUM(KLP9) KLP9, SUM(KLP10) KLP10, SUM(KLP11) KLP11, SUM(KLP12) KLP12, @TOTALKASUS TOTALKASUS
		FROM `master`.surveilans_penyakit_menular rl
			  LEFT JOIN (SELECT KODE KODEICD10,
								 COUNT(KODE) JUMLAH, 
								 SUM(IF(JENIS_KELAMIN=1,1,0)) JMLLAKI, 
								 SUM(IF(JENIS_KELAMIN=2,1,0)) JMLWANITA, 
								 SUM(IF(CARA IN (6,7),1,0)) JMLMATI,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=1,1,0)) KLP1,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=2,1,0)) KLP2,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=3,1,0)) KLP3,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=4,1,0)) KLP4,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=5,1,0)) KLP5,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=6,1,0)) KLP6,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=7,1,0)) KLP7,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=8,1,0)) KLP8,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=9,1,0)) KLP9,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=10,1,0)) KLP10,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=11,1,0)) KLP11,
								 SUM(IF(master.getKelompokUmurSurveilans(TANGGAL, TANGGAL_LAHIR)=12,1,0)) KLP12
   				FROM (
						SELECT md.KODE, ps.JENIS_KELAMIN, pp.TANGGAL,ps.TANGGAL_LAHIR, lpp.CARA
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
							  `master`.surveilans_penyakit_menular ic
						WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
							AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE_ICD10 AND md.BARU=1
							AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							GROUP BY pp.NORM
						) ab
				GROUP BY KODE
			  ) b ON b.KODEICD10=rl.KODE_ICD10
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
			GROUP BY DESKRIPSI_PENYAKIT_MENULAR
		  ORDER BY rl.ID');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
