-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk kemkes
USE `kemkes`;

-- membuang struktur untuk trigger kemkes.terkonfirmasi_tb_after_update
DROP TRIGGER IF EXISTS `terkonfirmasi_tb_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `terkonfirmasi_tb_after_update` AFTER UPDATE ON `terkonfirmasi_tb` FOR EACH ROW BEGIN
	DECLARE VNIK, VWILAYAH_FASKES, VWILAYAH_PASIEN, VKODE_FASKES, VRUANGAN, VNOMOR_BPJS VARCHAR(30);
	DECLARE VNAMA VARCHAR(75);
	DECLARE VJENIS_KELAMIN INT;
	DECLARE VALAMAT TEXT;
	DECLARE VTGL_LAHIR DATE;
	
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 2 THEN
		IF NOT EXISTS(SELECT 1 FROM kemkes.pasien_tb t WHERE t.nourut_pasien = OLD.NORM AND t.final = 0 LIMIT 1) THEN	
			SELECT p.NAMA, p.JENIS_KELAMIN, p.ALAMAT, kip.NOMOR, ins.WILAYAH, p.WILAYAH
					 , ins.KODE, kjgn.RUANGAN, p.TANGGAL_LAHIR, kap.NOMOR
			  INTO VNAMA, VJENIS_KELAMIN, VALAMAT, VNIK, VWILAYAH_FASKES, VWILAYAH_PASIEN
			  		 , VKODE_FASKES, VRUANGAN, VTGL_LAHIR, VNOMOR_BPJS
			  FROM `master`.pasien p
			       LEFT JOIN `master`.kartu_identitas_pasien kip ON kip.JENIS = 1 AND kip.NORM = p.NORM
			       LEFT JOIN `master`.kartu_asuransi_pasien kap ON kap.NORM = p.NORM AND kap.JENIS = 2
					 , (SELECT RUANGAN
							FROM pendaftaran.kunjungan k
						  WHERE k.NOMOR = OLD.KUNJUNGAN
						) kjgn
					 , (SELECT p.WILAYAH, p.KODE
							FROM aplikasi.instansi ai
								  , master.ppk p
						  WHERE ai.PPK=p.ID) ins
			 WHERE p.NORM = OLD.NORM LIMIT 1;
		
			INSERT INTO kemkes.pasien_tb (
				nourut_pasien, Nik, kd_pasien, jenis_kelamin, alamat_lengkap
				, tanggal_buat_laporan, tahun_buat_laporan
				, id_propinsi_faskes, kd_kabupaten_faskes
				, id_propinsi_pasien, kd_kabupaten_pasien
				, id_kecamatan_pasien, id_kelurahan, kd_fasyankes
				, tahun, kode_icd_x, Asal_poli, tgl_lahir, no_bpjs
			) VALUES (
				OLD.NORM, VNIK, VNAMA, VJENIS_KELAMIN, VALAMAT
				, OLD.TANGGAL, YEAR(OLD.TANGGAL)
				, SUBSTRING(VWILAYAH_FASKES, 1, 2), SUBSTRING(VWILAYAH_FASKES, 1, 4)
				, SUBSTRING(VWILAYAH_PASIEN, 1, 2), SUBSTRING(VWILAYAH_PASIEN, 1, 4)
			   , SUBSTRING(VWILAYAH_PASIEN, 1, 6), VWILAYAH_PASIEN, VKODE_FASKES
				, YEAR(OLD.TANGGAL), OLD.DIAGNOSA, VRUANGAN, VTGL_LAHIR, VNOMOR_BPJS);
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
