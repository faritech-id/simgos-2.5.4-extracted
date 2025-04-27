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

-- membuang struktur untuk procedure laporan.LaporanRL35
DROP PROCEDURE IF EXISTS `LaporanRL35`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL35`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME

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
						  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
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
						  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
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
						WHERE md.`STATUS`!=0 AND mdm.KODE=ic.ID AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
