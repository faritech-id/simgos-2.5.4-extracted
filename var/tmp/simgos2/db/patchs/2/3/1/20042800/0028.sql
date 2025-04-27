-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `kemkes`;

-- membuang struktur untuk trigger kemkes.pasien_before_update
DROP TRIGGER IF EXISTS `pasien_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pasien_before_update` BEFORE UPDATE ON `pasien` FOR EACH ROW BEGIN
	IF NEW.tglkeluar = '0000-00-00' THEN
		SET NEW.tglkeluar = NULL;
	END IF;
	
	IF NEW.tgl_lapor = '0000-00-00 00:00:00' THEN
		SET NEW.tgl_lapor = NULL;
	END IF;
	
	IF NEW.noc != OLD.noc
		OR NEW.initial != OLD.initial
		OR NEW.nama_lengkap != OLD.nama_lengkap
		OR NEW.tglmasuk != OLD.tglmasuk
		OR NEW.gender != OLD.gender
		OR NEW.birthdate != OLD.birthdate
		OR NEW.kewarganegaraan != OLD.kewarganegaraan
		OR NEW.sumber_penularan != OLD.sumber_penularan
		OR NEW.kecamatan != OLD.kecamatan
		OR NEW.tglkeluar != OLD.tglkeluar
		OR NEW.status_keluar != OLD.status_keluar
		OR NEW.tgl_lapor != OLD.tgl_lapor
		OR NEW.status_rawat != OLD.status_rawat
		OR NEW.status_keluar != OLD.status_keluar
		OR NEW.status_isolasi != OLD.status_isolasi
		OR NEW.email != OLD.email
		OR NEW.notelp != OLD.notelp
		OR NEW.sebab_kematian != OLD.sebab_kematian
	THEN
		SET NEW.kirim = 1;
	END IF;
	
	IF NEW.kirim != OLD.kirim AND OLD.kirim = 1 AND NEW.kirim = 0 AND NEW.response != NULL THEN
		SET NEW.tgl_kirim = NOW();
	END IF;
	
	IF NEW.kirim != OLD.kirim AND NEW.kirim = 1 AND OLD.kirim = 0 THEN
		SET NEW.response = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
