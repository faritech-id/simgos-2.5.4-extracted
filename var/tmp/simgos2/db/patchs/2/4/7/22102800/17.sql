-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
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

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL34
DROP PROCEDURE IF EXISTS `ambilDataRL34`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL34`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL34;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL34 ENGINE=MEMORY
	
	SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI, JUMLAH, RS, BIDAN, PUSKESMAS, FASKES, RUJUKANHIDUP, RUJUKANMATI, MEDISTOTAL, 
			 NONMEDISHIDUP, NONMEDISMATI, NONMEDISTOTAL, NONRUJUKANHIDUP, NONRUJUKANMATI, DIRUJUK
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT ic.RL34 ID, COUNT(md.NOPEN) JUMLAH
					, SUM(IF(pr.JENIS=1,1,0)) RS
					, 0 BIDAN
					, SUM(IF(pr.JENIS=2,1,0)) PUSKESMAS
					, SUM(IF(pr.JENIS NOT IN (1,2),1,0)) FASKES
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) RUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
					, SUM(IF(pp.RUJUKAN IS NOT NULL,1,0)) MEDISTOTAL
					, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONMEDISTOTAL
					, SUM(IF(pp.RUJUKAN IS NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) NONRUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
					, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
				FROM medicalrecord.diagnosa md
					, master.rl34_icd10 ic
					, pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
				WHERE md.`STATUS`!=0 AND md.KODE=ic.ID AND pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
				GROUP BY ic.RL34) rl34 ON rl34.ID=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				FROM aplikasi.instansi ai
					, master.ppk p
					, master.wilayah w
				WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=4
		ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-4` (tahun, `no`, jenis_kegiatan, rm_rumah_sakit, rm_bidan, rm_puskesmas, rm_faskes_lainnya, 
					rm_hidup, rm_mati, rm_total, rnm_hidup, rnm_mati, rnm_total, nr_hidup, nr_mati, nr_total, dirujuk)											
	SELECT TAHUN, KODE, DESKRIPSI, IFNULL(RS, 0), IFNULL(BIDAN, 0), IFNULL(PUSKESMAS, 0), IFNULL(FASKES, 0), IFNULL(RUJUKANHIDUP, 0), IFNULL(RUJUKANMATI, 0), IFNULL(MEDISTOTAL, 0), 
	       IFNULL(NONMEDISHIDUP, 0), IFNULL(NONMEDISMATI, 0), IFNULL(NONMEDISTOTAL, 0), IFNULL(NONRUJUKANHIDUP, 0), IFNULL(NONRUJUKANMATI, 0), IFNULL(JUMLAH, 0), IFNULL(DIRUJUK, 0)
  	  FROM TEMP_LAPORAN_RL34 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-4` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-4` r, TEMP_LAPORAN_RL34 t
	  SET r.rm_rumah_sakit = IFNULL(t.RS, 0),
			r.rm_bidan = IFNULL(t.BIDAN, 0),
			r.rm_puskesmas = IFNULL(t.PUSKESMAS, 0),
			r.rm_faskes_lainnya = IFNULL(t.FASKES, 0),
			r.rm_hidup = IFNULL(t.RUJUKANHIDUP, 0),
			r.rm_mati = IFNULL(t.RUJUKANMATI, 0),
			r.rm_total = IFNULL(t.MEDISTOTAL, 0),
			r.rnm_hidup = IFNULL(t.NONMEDISHIDUP, 0),
			r.rnm_mati = IFNULL(t.NONMEDISMATI, 0),
			r.rnm_total = IFNULL(t.NONMEDISTOTAL, 0),
			r.nr_hidup = IFNULL(t.NONRUJUKANHIDUP, 0),
			r.nr_mati = IFNULL(t.NONRUJUKANMATI, 0),
			r.nr_total = IFNULL(t.JUMLAH, 0),
			r.dirujuk = IFNULL(t.DIRUJUK, 0)	  
	WHERE r.tahun = t.TAHUN 
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk trigger kemkes-sirs.rl3-4_before_update
DROP TRIGGER IF EXISTS `rl3-4_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-4_before_update` BEFORE UPDATE ON `rl3-4` FOR EACH ROW BEGIN
	IF NEW.rm_rumah_sakit != OLD.rm_rumah_sakit
		OR NEW.rm_bidan != OLD.rm_bidan
		OR NEW.rm_puskesmas != OLD.rm_puskesmas
		OR NEW.rm_faskes_lainnya != OLD.rm_faskes_lainnya
		OR NEW.rm_hidup != OLD.rm_hidup
		OR NEW.rm_mati != OLD.rm_mati
		OR NEW.rm_total != OLD.rm_total 
		OR NEW.rnm_hidup != OLD.rnm_hidup
		OR NEW.rnm_mati != OLD.rnm_mati
		OR NEW.rnm_total != OLD.rnm_total
		OR NEW.nr_hidup != OLD.nr_hidup
		OR NEW.nr_mati != OLD.nr_mati
		OR NEW.nr_total != OLD.nr_total
		OR NEW.dirujuk != OLD.dirujuk THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
