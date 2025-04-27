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

-- Membuang data untuk tabel inacbg.tipe_inacbg: ~4 rows (lebih kurang)
/*!40000 ALTER TABLE `tipe_inacbg` DISABLE KEYS */;
REPLACE INTO `tipe_inacbg` (`ID`, `VERSION`, `NAMA`, `MASA_BERLAKU`, `STATUS`) VALUES
	(1, '4', 'non spesifik', '2016-10-25', 0),
	(2, '4', 'spesifik', '2016-10-25', 0),
	(3, '5', 'non spesifik', '2021-12-31', 1),
	(4, '5', 'spesifik', '2021-12-31', 0);
/*!40000 ALTER TABLE `tipe_inacbg` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
