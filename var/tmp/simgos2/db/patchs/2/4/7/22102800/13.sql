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

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL32
DROP PROCEDURE IF EXISTS `ambilDataRL32`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL32`(
	IN `PTAHUN` YEAR
)
BEGIN
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL32;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL32 ENGINE=MEMORY
    
	SELECT INST.*, PTAHUN TAHUN
				, rl.KODE, rl.DESKRIPSI
				, SUM(RUJUKAN) RUJUKAN, SUM(NONRUJUKAN) NONRUJUKAN
				, SUM((RUJUKAN+NONRUJUKAN)-(DIRUJUK+PULANG+MENINGGAL+DOA)) DIRAWAT
				, SUM(DIRUJUK) DIRUJUK
				, SUM(PULANG) PULANG
				, SUM(MENINGGAL) MENINGGAL
				, SUM(DOA) DOA
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT rl.RL32
  						, SUM(IF(pp.RUJUKAN IS NOT NULL,1,0)) RUJUKAN
						, SUM(IF(pp.RUJUKAN IS NULL,1,0)) NONRUJUKAN
						, 0 DIRUJUK
						, 0 PULANG
						, 0 MENINGGAL
						, 0 DOA
					FROM pendaftaran.pendaftaran pp
						, pendaftaran.tujuan_pasien tp
						, master.ruangan r
						, master.rl32_smf rl
					WHERE pp.`STATUS` IN (1,2) AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
						AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN=2
					GROUP BY rl.RL32
					UNION
				SELECT rl.RL32
						, 0 RUJUKAN
						, 0 NONRUJUKAN
						, SUM(IF(pp.CARA=3,1,0)) DIRUJUK
						, SUM(IF(pp.CARA NOT IN (6,7),1,0)) PULANG
						, SUM(IF(pp.CARA=6,1,0)) MENINGGAL
						, SUM(IF(pp.CARA=7,1,0)) DOA
					FROM layanan.pasien_pulang pp
						, pendaftaran.kunjungan pk
						, pendaftaran.tujuan_pasien tp
						, master.ruangan r
						, master.rl32_smf rl
					WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.`STATUS` IN (1,2)
						AND pk.RUANGAN=rl.ID AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
						AND pk.NOPEN=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN=2
					GROUP BY rl.RL32)b ON b.RL32=rl.ID
			   , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK = p.ID 
					  AND p.WILAYAH = w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=2
		GROUP BY rl.ID
		ORDER BY rl.ID;

	INSERT INTO `kemkes-sirs`.`rl3-2` (tahun, `no`, jenis_pelayanan, total_pasien_rujukan, total_pasien_non_rujukan, tindak_lanjut_pelayanan_dirawat,
		tindak_lanjut_pelayanan_dirujuk, tindak_lanjut_pelayanan_pulang, mati_di_ugd, doa)											
	SELECT TAHUN, KODE, DESKRIPSI, 
			 IFNULL(RUJUKAN, 0), IFNULL(NONRUJUKAN, 0), IFNULL(DIRAWAT, 0), IFNULL(DIRUJUK, 0), IFNULL(PULANG, 0), IFNULL(MENINGGAL, 0), IFNULL(DOA, 0)
  	  FROM TEMP_LAPORAN_RL32 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-2` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);
	
	UPDATE `kemkes-sirs`.`rl3-2` r, TEMP_LAPORAN_RL32 t
	  SET r.total_pasien_rujukan = IFNULL(t.RUJUKAN, 0),
			r.total_pasien_non_rujukan = IFNULL(t.NONRUJUKAN, 0),
			r.tindak_lanjut_pelayanan_dirawat = IFNULL(t.DIRAWAT, 0),
			r.tindak_lanjut_pelayanan_dirujuk = IFNULL(t.DIRUJUK, 0),
			r.tindak_lanjut_pelayanan_pulang = IFNULL(t.PULANG, 0),
			r.mati_di_ugd = IFNULL(t.MENINGGAL, 0),
			r.doa = IFNULL(t.DOA, 0)
	WHERE r.tahun = t.TAHUN
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk trigger kemkes-sirs.rl3-2_before_update
DROP TRIGGER IF EXISTS `rl3-2_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-2_before_update` BEFORE UPDATE ON `rl3-2` FOR EACH ROW BEGIN
	IF NEW.total_pasien_rujukan != OLD.total_pasien_rujukan
		OR NEW.total_pasien_non_rujukan != OLD.total_pasien_non_rujukan
		OR NEW.tindak_lanjut_pelayanan_dirawat != OLD.tindak_lanjut_pelayanan_dirawat
		OR NEW.tindak_lanjut_pelayanan_dirujuk != OLD.tindak_lanjut_pelayanan_dirujuk
		OR NEW.tindak_lanjut_pelayanan_pulang != OLD.tindak_lanjut_pelayanan_pulang
		OR NEW.mati_di_ugd != OLD.mati_di_ugd
		OR NEW.doa != OLD.doa THEN
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
