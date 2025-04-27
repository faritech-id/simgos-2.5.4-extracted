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

-- Membuang data untuk tabel lis.status_hasil: ~10 rows (lebih kurang)
/*!40000 ALTER TABLE `status_hasil` DISABLE KEYS */;
REPLACE INTO `status_hasil` (`ID`, `DESKRIPSI`, `STATUS`) VALUES
	(1, 'Hasil LIS Berhasil di terima', 1),
	(2, 'Hasil LIS berhasil di masukkan ke HIS', 1),
	(3, 'Hasil LIS tidak di support', 1),
	(4, 'No. Rekam Medis Pasien tidak valid', 1),
	(5, 'No. Pendaftaran terakhir yg masih aktif tdk ditemukan', 1),
	(6, 'Gagal membuat order otomatis', 1),
	(7, 'Gagal menerima order otomatis', 1),
	(8, 'Gagal membuat hasil LAB', 1),
	(9, 'Hasil LIS tidak valid', 1),
	(10, 'QC', 1);
/*!40000 ALTER TABLE `status_hasil` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
