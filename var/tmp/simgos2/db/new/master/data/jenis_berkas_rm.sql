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

-- Membuang data untuk tabel master.jenis_berkas_rm: 6 rows
/*!40000 ALTER TABLE `jenis_berkas_rm` DISABLE KEYS */;
REPLACE INTO `jenis_berkas_rm` (`JENIS`, `ID`, `DESKRIPSI`, `KODE`) VALUES
	(1, 1, 'IDENTITAS PASIEN', 'RM 0.0'),
	(3, 1, 'RINGKASAN MASUK DAN KELUAR', 'RM 0.0'),
	(3, 2, 'REGISTRASI RAWAT INAP', 'RM 0.0'),
	(2, 1, 'PENGKAJIAN AWAL MEDIS PASIEN IGD', 'RM 0.0'),
	(3, 3, 'RESUME MEDIS', 'RM 3.14'),
	(3, 4, 'LAPORAN OPERASI', 'MR.24/R.I');
/*!40000 ALTER TABLE `jenis_berkas_rm` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
