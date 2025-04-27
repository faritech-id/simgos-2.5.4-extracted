-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.26 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk informasi
#CREATE DATABASE IF NOT EXISTS `informasi` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `informasi`;

-- membuang struktur untuk trigger informasi.statistik_10_besar_diagnosa_rujukan_before_update
DROP TRIGGER IF EXISTS `statistik_10_besar_diagnosa_rujukan_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_10_besar_diagnosa_rujukan_before_update` BEFORE UPDATE ON `statistik_10_besar_diagnosa_rujukan` FOR EACH ROW BEGIN
	IF NEW.KONTEN != OLD.KONTEN THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_10_besar_penyakit_before_update
DROP TRIGGER IF EXISTS `statistik_10_besar_penyakit_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_10_besar_penyakit_before_update` BEFORE UPDATE ON `statistik_10_besar_penyakit` FOR EACH ROW BEGIN
	IF NEW.KONTEN != OLD.KONTEN THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_gol_darah_before_update
DROP TRIGGER IF EXISTS `statistik_gol_darah_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_gol_darah_before_update` BEFORE UPDATE ON `statistik_gol_darah` FOR EACH ROW BEGIN
	IF NEW.JUMLAH_PASIEN != OLD.JUMLAH_PASIEN THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_indikator_before_update
DROP TRIGGER IF EXISTS `statistik_indikator_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_indikator_before_update` BEFORE UPDATE ON `statistik_indikator` FOR EACH ROW BEGIN
	IF NEW.BOR != OLD.BOR OR NEW.ALOS != OLD.ALOS OR NEW.BTO != OLD.BTO OR NEW.TOI != OLD.TOI OR NEW.NDR != OLD.NDR OR NEW.GDR != OLD.GDR THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_jumlah_kematian_before_update
DROP TRIGGER IF EXISTS `statistik_jumlah_kematian_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_jumlah_kematian_before_update` BEFORE UPDATE ON `statistik_jumlah_kematian` FOR EACH ROW BEGIN
	IF NEW.KONTEN != OLD.KONTEN THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_kunjungan_before_update
DROP TRIGGER IF EXISTS `statistik_kunjungan_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_kunjungan_before_update` BEFORE UPDATE ON `statistik_kunjungan` FOR EACH ROW BEGIN
	IF NEW.RJ != OLD.RJ OR NEW.RD != OLD.RD OR NEW.RI != OLD.RI THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger informasi.statistik_rujukan_before_update
DROP TRIGGER IF EXISTS `statistik_rujukan_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `statistik_rujukan_before_update` BEFORE UPDATE ON `statistik_rujukan` FOR EACH ROW BEGIN
	IF NEW.MASUK != OLD.MASUK OR NEW.KELUAR != OLD.KELUAR OR NEW.BALIK != OLD.BALIK THEN
		SET NEW.KIRIM = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
