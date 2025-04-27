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

-- Membuang data untuk tabel master.jenis_ruangan: 5 rows
/*!40000 ALTER TABLE `jenis_ruangan` DISABLE KEYS */;
REPLACE INTO `jenis_ruangan` (`ID`, `DESKRIPSI`, `DIGIT`, `DELIMITER`) VALUES
	(1, 'Direktur Utama', 1, ''),
	(2, 'Direksi', 2, ''),
	(3, 'Bagian / Bidang / Instalasi', 2, ''),
	(4, 'Sub. Bagian / Seksi / Unit', 2, ''),
	(5, 'Sub. Unit', 2, '');
/*!40000 ALTER TABLE `jenis_ruangan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
