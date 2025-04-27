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

-- Membuang data untuk tabel aplikasi.info_teks: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `info_teks` DISABLE KEYS */;
REPLACE INTO `info_teks` (`ID`, `JENIS`, `TEKS`, `WARNA`, `PUBLISH`, `TANGGAL`, `OLEH`, `STATUS`) VALUES (1, 1, '', '', 1, '2020-03-04 08:49:12', 0, 1);
REPLACE INTO `info_teks` (`ID`, `JENIS`, `TEKS`, `WARNA`, `PUBLISH`, `TANGGAL`, `OLEH`, `STATUS`) VALUES (2, 2, 'Selamat Datang di SIMRSGos Versi 2 Kementerian Kesehatan Republik Indonesia', '54b6fa', 1, '2020-03-04 08:49:12', 0, 1);
/*!40000 ALTER TABLE `info_teks` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
