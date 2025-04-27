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

-- membuang struktur untuk trigger kemkes-sirs.rl3-10_before_update
DROP TRIGGER IF EXISTS `rl3-10_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-10_before_update` BEFORE UPDATE ON `rl3-10` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-11_before_update
DROP TRIGGER IF EXISTS `rl3-11_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-11_before_update` BEFORE UPDATE ON `rl3-11` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-12_before_update
DROP TRIGGER IF EXISTS `rl3-12_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-12_before_update` BEFORE UPDATE ON `rl3-12` FOR EACH ROW BEGIN
	IF NEW.kb_baru_dengan_cara_masuk_bukan_rujukan != OLD.kb_baru_dengan_cara_masuk_bukan_rujukan
		OR NEW.kb_baru_dengan_cara_masuk_rujukan_r_inap != OLD.kb_baru_dengan_cara_masuk_rujukan_r_inap
		OR NEW.kb_baru_dengan_cara_masuk_rujukan_r_jalan != OLD.kb_baru_dengan_cara_masuk_rujukan_r_jalan
		OR NEW.kb_baru_dengan_cara_masuk_total != OLD.kb_baru_dengan_cara_masuk_total
		OR NEW.kb_baru_dengan_kondisi_pasca_persalinan_atau_nifas != OLD.kb_baru_dengan_kondisi_pasca_persalinan_atau_nifas
		OR NEW.kb_baru_dengan_kondisi_abortus != OLD.kb_baru_dengan_kondisi_abortus 
		OR NEW.kb_baru_dengan_kondisi_lainnya != OLD.kb_baru_dengan_kondisi_lainnya
		OR NEW.kunjungan_ulang != OLD.kunjungan_ulang 
		OR NEW.keluhan_efek_samping_jumlah != OLD.keluhan_efek_samping_jumlah
		OR NEW.keluhan_efek_samping_dirujuk != OLD.keluhan_efek_samping_dirujuk THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-13b_before_update
DROP TRIGGER IF EXISTS `rl3-13b_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-13b_before_update` BEFORE UPDATE ON `rl3-13b` FOR EACH ROW BEGIN
	IF NEW.rawat_jalan != OLD.rawat_jalan
		OR NEW.igd != OLD.igd
		OR NEW.rawat_inap != OLD.rawat_inap THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-13_before_update
DROP TRIGGER IF EXISTS `rl3-13_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-13_before_update` BEFORE UPDATE ON `rl3-13` FOR EACH ROW BEGIN
	IF NEW.jumlah_item_obat != OLD.jumlah_item_obat
		OR NEW.jumlah_item_obat_yang_tersedia_di_rs != OLD.jumlah_item_obat_yang_tersedia_di_rs
		OR NEW.jumlah_item_obat_formulatorium_yang_tersedia_di_rs != OLD.jumlah_item_obat_formulatorium_yang_tersedia_di_rs THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-14_before_update
DROP TRIGGER IF EXISTS `rl3-14_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-14_before_update` BEFORE UPDATE ON `rl3-14` FOR EACH ROW BEGIN
	IF NEW.rujukan_diterima_dari_puskesmas != OLD.rujukan_diterima_dari_puskesmas
		OR NEW.rujukan_diterima_dari_faskes_lainnya != OLD.rujukan_diterima_dari_faskes_lainnya
		OR NEW.rujukan_diterima_dari_rs_lain != OLD.rujukan_diterima_dari_rs_lain
		OR NEW.rujukan_dikembalikan_ke_puskesmas != OLD.rujukan_dikembalikan_ke_puskesmas
		OR NEW.rujukan_dikembalikan_ke_faskes_lainnya != OLD.rujukan_dikembalikan_ke_faskes_lainnya
		OR NEW.rujukan_dikembalikan_ke_rs_asal != OLD.rujukan_dikembalikan_ke_rs_asal
		OR NEW.dirujuk_pasien_rujukan != OLD.dirujuk_pasien_rujukan
		OR NEW.dirujuk_pasien_datang_sendiri != OLD.dirujuk_pasien_datang_sendiri
		OR NEW.dirujuk_diterima_kembali != OLD.dirujuk_diterima_kembali THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-15_before_update
DROP TRIGGER IF EXISTS `rl3-15_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-15_before_update` BEFORE UPDATE ON `rl3-15` FOR EACH ROW BEGIN
	IF NEW.pasien_rawat_inap_jpk != OLD.pasien_rawat_inap_jpk
		OR NEW.pasien_rawat_inap_jld != OLD.pasien_rawat_inap_jld
		OR NEW.jumlah_pasien_rawat_jalan != OLD.jumlah_pasien_rawat_jalan
		OR NEW.jumlah_pasien_rawat_jalan_lab != OLD.jumlah_pasien_rawat_jalan_lab
		OR NEW.jumlah_pasien_rawat_jalan_rad != OLD.jumlah_pasien_rawat_jalan_rad
		OR NEW.jumlah_pasien_rawat_jalan_ll != OLD.jumlah_pasien_rawat_jalan_ll THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-5_before_update
DROP TRIGGER IF EXISTS `rl3-5_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-5_before_update` BEFORE UPDATE ON `rl3-5` FOR EACH ROW BEGIN
	IF NEW.rm_rumah_sakit != OLD.rm_rumah_sakit
		OR NEW.rm_bidan != OLD.rm_bidan
		OR NEW.rm_puskesmas != OLD.rm_puskesmas
		OR NEW.rm_faskes_lainnya != OLD.rm_faskes_lainnya
		OR NEW.rm_mati != OLD.rm_mati
		OR NEW.rm_total != OLD.rm_total 
		OR NEW.rnm_mati != OLD.rnm_mati
		OR NEW.rnm_total != OLD.rnm_total
		OR NEW.nr_mati != OLD.nr_mati
		OR NEW.nr_total != OLD.nr_total
		OR NEW.dirujuk != OLD.dirujuk THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-6_before_update
DROP TRIGGER IF EXISTS `rl3-6_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-6_before_update` BEFORE UPDATE ON `rl3-6` FOR EACH ROW BEGIN
	IF NEW.total != OLD.total
		OR NEW.khusus != OLD.khusus
		OR NEW.besar != OLD.besar
		OR NEW.sedang != OLD.sedang
		OR NEW.kecil != OLD.kecil THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-7_before_update
DROP TRIGGER IF EXISTS `rl3-7_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-7_before_update` BEFORE UPDATE ON `rl3-7` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-8_before_update
DROP TRIGGER IF EXISTS `rl3-8_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-8_before_update` BEFORE UPDATE ON `rl3-8` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl3-9_before_update
DROP TRIGGER IF EXISTS `rl3-9_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-9_before_update` BEFORE UPDATE ON `rl3-9` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl4a-sebab_before_update
DROP TRIGGER IF EXISTS `rl4a-sebab_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `rl4a-sebab_before_update` BEFORE UPDATE ON `rl4a-sebab` FOR EACH ROW BEGIN
   IF NEW.`jumlah_pasien_hidup_mati_0-<=6_hari_l` != OLD.`jumlah_pasien_hidup_mati_0-<=6_hari_l`
		OR NEW.`jumlah_pasien_hidup_mati_0-<=6_hari_p` != OLD.`jumlah_pasien_hidup_mati_0-<=6_hari_p`
		OR NEW.`jumlah_pasien_hidup_mati_>6-<=28_hari_l` != OLD.`jumlah_pasien_hidup_mati_>6-<=28_hari_l`
		OR NEW.`jumlah_pasien_hidup_mati_>6-<=28_hari_p` != OLD.`jumlah_pasien_hidup_mati_>6-<=28_hari_p`
		OR NEW.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>64_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>64_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>64_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>64_tahun_p`
		OR NEW.`pasien_keluar_hidup_mati_l` != OLD.`pasien_keluar_hidup_mati_l`
		OR NEW.`pasien_keluar_hidup_mati_p` != OLD.`pasien_keluar_hidup_mati_p`
		OR NEW.`jumlah_pasien_keluar_hidup_mati` != OLD.`jumlah_pasien_keluar_hidup_mati`
		OR NEW.`jumlah_pasien_keluar_mati` != OLD.`jumlah_pasien_keluar_mati` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl4a_before_update
DROP TRIGGER IF EXISTS `rl4a_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl4a_before_update` BEFORE UPDATE ON `rl4a` FOR EACH ROW BEGIN
	IF NEW.`jumlah_pasien_hidup_mati_0-<=6_hari_l` != OLD.`jumlah_pasien_hidup_mati_0-<=6_hari_l`
		OR NEW.`jumlah_pasien_hidup_mati_0-<=6_hari_p` != OLD.`jumlah_pasien_hidup_mati_0-<=6_hari_p`
		OR NEW.`jumlah_pasien_hidup_mati_>6-<=28_hari_l` != OLD.`jumlah_pasien_hidup_mati_>6-<=28_hari_l`
		OR NEW.`jumlah_pasien_hidup_mati_>6-<=28_hari_p` != OLD.`jumlah_pasien_hidup_mati_>6-<=28_hari_p`
		OR NEW.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p`
		OR NEW.`jumlah_pasien_hidup_mati_>64_tahun_l` != OLD.`jumlah_pasien_hidup_mati_>64_tahun_l`
		OR NEW.`jumlah_pasien_hidup_mati_>64_tahun_p` != OLD.`jumlah_pasien_hidup_mati_>64_tahun_p`
		OR NEW.`pasien_keluar_hidup_mati_l` != OLD.`pasien_keluar_hidup_mati_l`
		OR NEW.`pasien_keluar_hidup_mati_p` != OLD.`pasien_keluar_hidup_mati_p`
		OR NEW.`jumlah_pasien_keluar_hidup_mati` != OLD.`jumlah_pasien_keluar_hidup_mati`
		OR NEW.`jumlah_pasien_keluar_mati` != OLD.`jumlah_pasien_keluar_mati` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl4b-sebab_before_update
DROP TRIGGER IF EXISTS `rl4b-sebab_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl4b-sebab_before_update` BEFORE UPDATE ON `rl4b-sebab` FOR EACH ROW BEGIN
	IF NEW.`0-<=6_hari_l` != OLD.`0-<=6_hari_l`
		OR NEW.`0-<=6_hari_p` != OLD.`0-<=6_hari_p`
		OR NEW.`>6-<=28_hari_l` != OLD.`>6-<=28_hari_l`
		OR NEW.`>6-<=28_hari_p` != OLD.`>6-<=28_hari_p`
		OR NEW.`>28_hari-<=1_tahun_l` != OLD.`>28_hari-<=1_tahun_l`
		OR NEW.`>28_hari-<=1_tahun_p` != OLD.`>28_hari-<=1_tahun_p`
		OR NEW.`>1-<=4_tahun_l` != OLD.`>1-<=4_tahun_l`
		OR NEW.`>1-<=4_tahun_p` != OLD.`>1-<=4_tahun_p`
		OR NEW.`>4-<=14_tahun_l` != OLD.`>4-<=14_tahun_l`
		OR NEW.`>4-<=14_tahun_p` != OLD.`>4-<=14_tahun_p`
		OR NEW.`>14-<=24_tahun_l` != OLD.`>14-<=24_tahun_l`
		OR NEW.`>14-<=24_tahun_p` != OLD.`>14-<=24_tahun_p`
		OR NEW.`>24-<=44_tahun_l` != OLD.`>24-<=44_tahun_l`
		OR NEW.`>24-<=44_tahun_p` != OLD.`>24-<=44_tahun_p`
		OR NEW.`>44-<=64_tahun_l` != OLD.`>44-<=64_tahun_l`
		OR NEW.`>44-<=64_tahun_p` != OLD.`>44-<=64_tahun_p`
		OR NEW.`>64_tahun_l` != OLD.`>64_tahun_l`
		OR NEW.`>64_tahun_p` != OLD.`>64_tahun_p`
		OR NEW.`kasus_baru_menurut_jenis_kelamain_l` != OLD.`kasus_baru_menurut_jenis_kelamain_l`
		OR NEW.`kasus_baru_menurut_jenis_kelamain_p` != OLD.`kasus_baru_menurut_jenis_kelamain_p`
		OR NEW.`jumlah_kasus_baru` != OLD.`jumlah_kasus_baru`
		OR NEW.`jumlah_kunjungan` != OLD.`jumlah_kunjungan` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl4b_before_update
DROP TRIGGER IF EXISTS `rl4b_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl4b_before_update` BEFORE UPDATE ON `rl4b` FOR EACH ROW BEGIN
	IF NEW.`0-<=6_hari_l` != OLD.`0-<=6_hari_l`
		OR NEW.`0-<=6_hari_p` != OLD.`0-<=6_hari_p`
		OR NEW.`>6-<=28_hari_l` != OLD.`>6-<=28_hari_l`
		OR NEW.`>6-<=28_hari_p` != OLD.`>6-<=28_hari_p`
		OR NEW.`>28_hari-<=1_tahun_l` != OLD.`>28_hari-<=1_tahun_l`
		OR NEW.`>28_hari-<=1_tahun_p` != OLD.`>28_hari-<=1_tahun_p`
		OR NEW.`>1-<=4_tahun_l` != OLD.`>1-<=4_tahun_l`
		OR NEW.`>1-<=4_tahun_p` != OLD.`>1-<=4_tahun_p`
		OR NEW.`>4-<=14_tahun_l` != OLD.`>4-<=14_tahun_l`
		OR NEW.`>4-<=14_tahun_p` != OLD.`>4-<=14_tahun_p`
		OR NEW.`>14-<=24_tahun_l` != OLD.`>14-<=24_tahun_l`
		OR NEW.`>14-<=24_tahun_p` != OLD.`>14-<=24_tahun_p`
		OR NEW.`>24-<=44_tahun_l` != OLD.`>24-<=44_tahun_l`
		OR NEW.`>24-<=44_tahun_p` != OLD.`>24-<=44_tahun_p`
		OR NEW.`>44-<=64_tahun_l` != OLD.`>44-<=64_tahun_l`
		OR NEW.`>44-<=64_tahun_p` != OLD.`>44-<=64_tahun_p`
		OR NEW.`>64_tahun_l` != OLD.`>64_tahun_l`
		OR NEW.`>64_tahun_p` != OLD.`>64_tahun_p`
		OR NEW.`kasus_baru_menurut_jenis_kelamain_l` != OLD.`kasus_baru_menurut_jenis_kelamain_l`
		OR NEW.`kasus_baru_menurut_jenis_kelamain_p` != OLD.`kasus_baru_menurut_jenis_kelamain_p`
		OR NEW.`jumlah_kasus_baru` != OLD.`jumlah_kasus_baru`
		OR NEW.`jumlah_kunjungan` != OLD.`jumlah_kunjungan` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl5-1_before_update
DROP TRIGGER IF EXISTS `rl5-1_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl5-1_before_update` BEFORE UPDATE ON `rl5-1` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
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
