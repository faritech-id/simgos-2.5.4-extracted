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

-- Membuang data untuk tabel inacbg.jenis_inacbg: ~10 rows (lebih kurang)
/*!40000 ALTER TABLE `jenis_inacbg` DISABLE KEYS */;
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES
	(1, 'Kode Inacbg'),
	(2, 'CMG Inacbg'),
	(3, 'Special Drug'),
	(4, 'Special Prosthesis'),
	(5, 'Special Investigation'),
	(6, 'Special Procedure'),
	(7, 'ADL'),
	(8, 'Kelas Hak'),
	(9, 'Cara Keluar'),
	(10, 'Jenis Tarif'),
	(11, 'Status Covid 19'),
	(12, 'Episodes'),
	(13, 'Jenis Kartu Identitas'),
	(14, 'Komorbid / Komplikasi');
/*!40000 ALTER TABLE `jenis_inacbg` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
