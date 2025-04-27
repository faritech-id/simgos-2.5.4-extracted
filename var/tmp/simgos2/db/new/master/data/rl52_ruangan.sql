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

-- Membuang data untuk tabel master.rl52_ruangan: ~23 rows (lebih kurang)
/*!40000 ALTER TABLE `rl52_ruangan` DISABLE KEYS */;
REPLACE INTO `rl52_ruangan` (`ID`, `RL52`) VALUES
	('1', 1),
	('13', 2),
	('18', 3),
	('19', 3),
	('20', 3),
	('21', 3),
	('22', 3),
	('23', 3),
	('24', 3),
	('11', 4),
	('4', 6),
	('10', 8),
	('15', 9),
	('2', 10),
	('14', 13),
	('7', 13),
	('3', 14),
	('12', 15),
	('5', 16),
	('16', 18),
	('8', 20),
	('33', 21),
	('29', 25);
/*!40000 ALTER TABLE `rl52_ruangan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
