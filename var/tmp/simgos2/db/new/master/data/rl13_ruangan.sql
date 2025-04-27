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

-- Membuang data untuk tabel master.rl13_ruangan: ~23 rows (lebih kurang)
/*!40000 ALTER TABLE `rl13_ruangan` DISABLE KEYS */;
REPLACE INTO `rl13_ruangan` (`ID`, `RL13`) VALUES
	('1', 1),
	('9', 1),
	('11', 2),
	('4', 3),
	('13', 5),
	('18', 5),
	('19', 5),
	('20', 5),
	('21', 5),
	('22', 5),
	('23', 5),
	('24', 5),
	('8', 6),
	('10', 7),
	('15', 9),
	('2', 10),
	('14', 13),
	('7', 13),
	('3', 14),
	('12', 15),
	('16', 16),
	('33', 17),
	('5', 28);
/*!40000 ALTER TABLE `rl13_ruangan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
