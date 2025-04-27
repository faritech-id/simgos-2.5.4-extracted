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

-- Membuang data untuk tabel inacbg.map_inacbg_simrs: ~32 rows (lebih kurang)
/*!40000 ALTER TABLE `map_inacbg_simrs` DISABLE KEYS */;
REPLACE INTO `map_inacbg_simrs` (`JENIS`, `INACBG`, `SIMRS`, `VERSION`) VALUES
	(1, '1', '3', '4'),
	(1, '1', '3', '5'),
	(1, '2', '1', '4'),
	(1, '2', '1', '5'),
	(1, '2', '2', '4'),
	(1, '2', '2', '5'),
	(2, '1', '1', '4'),
	(2, '1', '1', '5'),
	(2, '2', '3', '4'),
	(2, '2', '3', '5'),
	(2, '3', '2', '4'),
	(2, '3', '2', '5'),
	(2, '3', '4', '4'),
	(2, '3', '4', '5'),
	(2, '4', '6', '4'),
	(2, '4', '6', '5'),
	(2, '4', '7', '4'),
	(2, '4', '7', '5'),
	(2, '5', '5', '4'),
	(2, '5', '5', '5'),
	(3, '3', '2', '5'),
	(3, '5', '2', '4'),
	(4, '1', '3', '4'),
	(4, '1', '3', '5'),
	(4, '2', '2', '4'),
	(4, '2', '2', '5'),
	(4, '3', '1', '4'),
	(4, '3', '1', '5'),
	(6, 'kelas_1', '3', '5'),
	(6, 'kelas_2', '2', '5'),
	(6, 'vip', '4', '5'),
	(6, 'vvip', '5', '5');
/*!40000 ALTER TABLE `map_inacbg_simrs` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
