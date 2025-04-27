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

-- Membuang data untuk tabel inacbg.map_tarif: ~8 rows (lebih kurang)
/*!40000 ALTER TABLE `map_tarif` DISABLE KEYS */;
REPLACE INTO `map_tarif` (`KELASRS`, `KEPEMILIKAN`, `TIPE`, `JENISTARIF`) VALUES
	('A', 'P', 3, 'AP'),
	('A', 'S', 3, 'AS'),
	('B', 'P', 3, 'BP'),
	('B', 'S', 3, 'BS'),
	('C', 'P', 3, 'CP'),
	('C', 'S', 3, 'CS'),
	('D', 'P', 3, 'DP'),
	('D', 'S', 3, 'DS');
/*!40000 ALTER TABLE `map_tarif` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
