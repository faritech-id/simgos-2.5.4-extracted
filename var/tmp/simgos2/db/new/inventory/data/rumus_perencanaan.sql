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

-- Membuang data untuk tabel inventory.rumus_perencanaan: ~28 rows (lebih kurang)
/*!40000 ALTER TABLE `rumus_perencanaan` DISABLE KEYS */;
REPLACE INTO `rumus_perencanaan` (`ID_RUMUS`, `KATEGORI`, `PERIODE_PERENCANAAN`, `VOLUME_PRESENTASE`, `LEAD_TIME`, `STATUS`, `OLEH`, `UPDATE_TIME`) VALUES
	(1, 'A', 1, 20, 7, 0, 136, '2016-05-27 16:56:23'),
	(2, 'B', 1, 20, 7, 0, 136, '2016-05-27 16:52:42'),
	(3, 'C', 1, 15, 0, 0, 1, '2016-05-27 16:08:56'),
	(4, 'C', 1, 15, 1, 0, 136, '2016-05-27 16:38:54'),
	(5, 'C', 1, 5, 7, 0, 136, '2016-05-27 16:45:17'),
	(6, 'C', 1, 10, 7, 0, 136, '2016-05-27 16:48:03'),
	(7, 'C', 1, 5, 0, 0, 136, '2016-05-27 16:50:17'),
	(8, 'C', 1, 12, 1, 0, 136, '2016-05-27 16:52:11'),
	(9, 'C', 1, 10, 1, 0, 136, '2016-05-27 16:52:27'),
	(10, 'C', 1, 5, 1, 0, 136, '2016-05-27 16:56:48'),
	(11, 'B', 1, 15, 3, 0, 136, '2016-05-27 16:56:38'),
	(12, 'A', 4, 20, 7, 0, 136, '2016-05-27 17:06:27'),
	(13, 'B', 4, 10, 7, 0, 136, '2016-05-27 16:59:42'),
	(14, 'C', 0, 10, 7, 0, 136, '2016-05-27 16:56:59'),
	(15, 'C', 4, 10, 7, 0, 136, '2016-05-27 16:59:55'),
	(16, 'B', 4, 10, 0, 0, 136, '2016-05-27 17:04:15'),
	(17, 'C', 4, 10, 0, 0, 136, '2016-05-27 17:04:20'),
	(18, 'B', 4, 5, 0, 0, 136, '2016-07-01 15:49:28'),
	(19, 'C', 4, 5, 0, 0, 136, '2016-07-01 15:49:49'),
	(20, 'A', 4, 20, 5, 0, 136, '2016-05-27 17:12:35'),
	(21, 'A', 4, 15, 5, 0, 136, '2016-07-01 15:49:17'),
	(22, 'A', 4, 15, 5, 0, 136, '2016-07-01 15:49:57'),
	(23, 'B', 16, 5, 0, 0, 1, '2017-01-30 12:07:45'),
	(24, 'C', 16, 5, 0, 1, 136, '2016-07-01 15:49:44'),
	(25, 'A', 16, 15, 5, 0, 136, '2017-02-08 11:34:02'),
	(26, 'B', 16, 10, 5, 1, 1, '2017-01-30 12:07:31'),
	(27, 'A', 4, 15, 5, 0, 1, '2017-12-06 17:20:37'),
	(28, 'A', 4, 15, 5, 1, 1, '2017-12-06 17:20:30');
/*!40000 ALTER TABLE `rumus_perencanaan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
