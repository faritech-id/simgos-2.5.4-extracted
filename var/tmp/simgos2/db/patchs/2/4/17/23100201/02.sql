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


-- Membuang struktur basisdata untuk kemkes-sirs
USE `kemkes-sirs`;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL4ASebab
DROP PROCEDURE IF EXISTS `ambilDataRL4ASebab`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL4ASebab`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL4ASEBAB;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL4ASEBAB (
		TAHUN YEAR, 
		KODE CHAR(10), 
		ID SMALLINT(5), 
		NODAFTAR VARCHAR(200), 
		DESKRIPSI VARCHAR(200), 
		KLP1LAKI SMALLINT(5), 
		KLP1WANITA SMALLINT(5), 
		KLP2LAKI SMALLINT(5), 
		KLP2WANITA SMALLINT(5), 
		KLP3LAKI SMALLINT(5), 
		KLP3WANITA SMALLINT(5), 
		KLP4LAKI SMALLINT(5),
		KLP4WANITA SMALLINT(5), 
		KLP5LAKI SMALLINT(5), 
		KLP5WANITA SMALLINT(5), 
		KLP6LAKI SMALLINT(5), 
		KLP6WANITA SMALLINT(5), 
		KLP7LAKI SMALLINT(5), 
		KLP7WANITA SMALLINT(5), 
		KLP8LAKI SMALLINT(5), 
		KLP8WANITA SMALLINT(5), 
		KLP9LAKI SMALLINT(5), 
		KLP9WANITA SMALLINT(5), 
		JMLLAKI SMALLINT(5), 
		JMLWANITA SMALLINT(5), 
		JUMLAH SMALLINT(5), 
		JMLMATI SMALLINT(5)
   	) ENGINE=MEMORY;
   INSERT INTO TEMP_LAPORAN_RL4ASEBAB 
	SELECT 
	
		PTAHUN TAHUN, rl.KODE, rl.ID, rl.NODAFTAR, rl.DESKRIPSI, KLP1LAKI, KLP1WANITA, KLP2LAKI, KLP2WANITA, KLP3LAKI, KLP3WANITA, KLP4LAKI,
					 KLP4WANITA, KLP5LAKI, KLP5WANITA, KLP6LAKI, KLP6WANITA, KLP7LAKI, KLP7WANITA, KLP8LAKI, KLP8WANITA, KLP9LAKI, KLP9WANITA, JMLLAKI, JMLWANITA, JUMLAH, JMLMATI
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
	
					 COUNT(md.KODE) JUMLAH
					 , SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI
					 , SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA
					 , SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
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
				  LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pk.NOPEN AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3 AND md.KODE=ic.KODE
					AND pk.NOPEN=pp.NOMOR AND lpp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100104' AND jrl.ID=2
		ORDER BY rl.ID;
	
	INSERT INTO 
				`kemkes-sirs`.`rl4a-sebab` (`tahun`,  `no_dtd`,  `no_urut`,  `no_daftar_terperinci`,  `golongan_sebab_penyakit`,  `jumlah_pasien_hidup_mati_0-<=6_hari_l`,  
				`jumlah_pasien_hidup_mati_0-<=6_hari_p`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_l`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_p`,  `jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l`,
				`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_l`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_p`,  `jumlah_pasien_hidup_mati_>4-<=14_tahun_l`, 
				`jumlah_pasien_hidup_mati_>4-<=14_tahun_p`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_l`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_p`,  `jumlah_pasien_hidup_mati_>24-<=44_tahun_l`, 
				`jumlah_pasien_hidup_mati_>24-<=44_tahun_p`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_l`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_p`,  `jumlah_pasien_hidup_mati_>64_tahun_l`, 
				`jumlah_pasien_hidup_mati_>64_tahun_p`,  `pasien_keluar_hidup_mati_l`,  `pasien_keluar_hidup_mati_p`,  `jumlah_pasien_keluar_hidup_mati`,  `jumlah_pasien_keluar_mati`)											
	SELECT TAHUN, KODE, ID, NODAFTAR, DESKRIPSI, 
			 IFNULL(KLP1LAKI, 0), IFNULL(KLP1WANITA, 0), 
			 IFNULL(KLP2LAKI, 0), IFNULL(KLP2WANITA, 0), 
			 IFNULL(KLP3LAKI, 0), IFNULL(KLP3WANITA, 0), 
			 IFNULL(KLP4LAKI, 0), IFNULL(KLP4WANITA, 0), 
			 IFNULL(KLP5LAKI, 0), IFNULL(KLP5WANITA, 0), 
			 IFNULL(KLP6LAKI, 0), IFNULL(KLP6WANITA, 0), 
			 IFNULL(KLP7LAKI, 0), IFNULL(KLP7WANITA, 0), 
			 IFNULL(KLP8LAKI, 0), IFNULL(KLP8WANITA, 0), 
			 IFNULL(KLP9LAKI, 0), IFNULL(KLP9WANITA, 0), 
			 IFNULL(JMLLAKI, 0), IFNULL(JMLWANITA, 0), IFNULL(JUMLAH, 0), IFNULL(JMLMATI, 0)
  	  FROM TEMP_LAPORAN_RL4ASEBAB t
	 WHERE NOT EXISTS (SELECT 1 FROM `kemkes-sirs`.`rl4a-sebab` r WHERE r.tahun = t.TAHUN AND r.`no_dtd` = t.KODE);

	UPDATE `kemkes-sirs`.`rl4a-sebab` r, TEMP_LAPORAN_RL4ASEBAB t
	   SET r.`jumlah_pasien_hidup_mati_0-<=6_hari_l` = IFNULL(t.KLP1LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_0-<=6_hari_p` = IFNULL(t.KLP1WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_l` = IFNULL(t.KLP2LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_p` = IFNULL(t.KLP2WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l` = IFNULL(t.KLP3LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p` = IFNULL(t.KLP3WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l` = IFNULL(t.KLP4LAKI, 0),
		 	 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p` = IFNULL(t.KLP4WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l` = IFNULL(t.KLP5LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p` = IFNULL(t.KLP5WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l` = IFNULL(t.KLP6LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p` = IFNULL(t.KLP6WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l` = IFNULL(t.KLP7LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p` = IFNULL(t.KLP7WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l` = IFNULL(t.KLP8LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p` = IFNULL(t.KLP8WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_l` = IFNULL(t.KLP9LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_p` = IFNULL(t.KLP9WANITA, 0),
			 r.`pasien_keluar_hidup_mati_l` = IFNULL(t.JMLLAKI, 0),
			 r.`pasien_keluar_hidup_mati_p` = IFNULL(t.JMLWANITA, 0),
			 r.`jumlah_pasien_keluar_hidup_mati` = IFNULL(t.JUMLAH, 0),
			 r.`jumlah_pasien_keluar_mati` = IFNULL(t.JMLMATI, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no_dtd` = t.KODE;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
