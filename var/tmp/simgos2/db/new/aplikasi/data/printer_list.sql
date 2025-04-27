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

-- Membuang data untuk tabel aplikasi.printer_list: ~12 rows (lebih kurang)
/*!40000 ALTER TABLE `printer_list` DISABLE KEYS */;
REPLACE INTO `printer_list` (`ID`, `NAMA`, `UKURANKERTAS`) VALUES
	(1, 'CetakKartu', NULL),
	(2, 'CetakBukti', 'Lebar=9,49 cm, Tinggi=13,97 cm'),
	(3, 'CetakTracert', NULL),
	(4, 'CetakMR', NULL),
	(5, 'CetakSEP', 'Lebar=20,99 cm, Tinggi=9,172 cm'),
	(6, 'CetakBarcodePasien', 'Lebar=10 cm, Tinggi= 4 cm'),
	(7, 'CetakBarcodePendaftaran', 'Lebar=10 cm, Tinggi= 2,80 cm'),
	(8, 'CetakKwitansi', NULL),
	(9, 'CetakRincian', NULL),
	(10, 'CetakResep', NULL),
	(11, 'CetakHasil', NULL),
	(12, 'CetakEtiket', 'Lebar = 5 cm, Tinggi = 6 cm'),
	(13, 'CetakJobList', NULL);
/*!40000 ALTER TABLE `printer_list` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
