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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk trigger layanan.jasa_tuslah_farmasi_after_insert
DROP TRIGGER IF EXISTS `jasa_tuslah_farmasi_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `jasa_tuslah_farmasi_after_insert` AFTER INSERT ON `jasa_tuslah_farmasi` FOR EACH ROW BEGIN		
	INSERT INTO layanan.farmasi
	(ID, KUNJUNGAN, FARMASI, JUMLAH, ATURAN_PAKAI, KETERANGAN, RACIKAN, GROUP_RACIKAN, PETUNJUK_RACIKAN, TANGGAL, OLEH)
	VALUES
	(NEW.ID, NEW.KUNJUNGAN, NEW.FARMASI, NEW.JUMLAH, '0', '-', 0, 0, '', NOW(), NEW.OLEH);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
