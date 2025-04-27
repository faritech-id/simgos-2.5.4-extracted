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

-- Membuang data untuk tabel master.kemkes_kelas: ~8 rows (lebih kurang)
/*!40000 ALTER TABLE `kemkes_kelas` DISABLE KEYS */;
REPLACE INTO `kemkes_kelas` (`ID`, `DESKRIPSI`) VALUES
	('0001', 'Super VIP'),
	('0002', 'VIP'),
	('0003', 'Kelas 1'),
	('0004', 'Kelas 2'),
	('0005', 'Kelas 3'),
	('0006', 'Intermediate'),
	('0007', 'Isolasi'),
	('0008', 'Rawat Khusus');
/*!40000 ALTER TABLE `kemkes_kelas` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
