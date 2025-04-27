-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang data untuk tabel master.jenis_peserta_penjamin: 0 rows
/*!40000 ALTER TABLE `jenis_peserta_penjamin` DISABLE KEYS */;
REPLACE INTO `jenis_peserta_penjamin` (`JENIS`, `ID`, `DESKRIPSI`, `STATUS`) VALUES
	(1, 0, '-', 1),
    (2, 0, 'TIDAK DIKETAHUI', 1),
	(2, 1, 'PNS PUSAT', 1),
	(2, 2, 'PNS PUSAT DIPERBANTUKAN', 1),
	(2, 3, 'PNS DAERAH', 1),
	(2, 4, 'PNS DAERAH DIPERBANTUKAN', 1),
	(2, 5, 'PRAJURIT AD', 1),
	(2, 6, 'PRAJURIT AL', 1),
	(2, 7, 'PRAJURIT AU', 1),
	(2, 8, 'ANGGOTA POLRI', 1),
	(2, 9, 'PEJABAT NEGARA', 1),
	(2, 10, 'PEGAWAI PEMERINTAH DENGAN PERJANJIAN', 1),
	(2, 11, 'PEGAWAI BUMN', 1),
	(2, 12, 'PEGAWAI BUMD', 1),
	(2, 13, 'PEGAWAI SWASTA', 1),
	(2, 14, 'PEKERJA MANDIRI', 1),
	(2, 15, 'PENERIMA PENSIUN PNS', 1),
	(2, 16, 'PENERIMA PENSIUN TNI', 1),
	(2, 17, 'PENERIMA PENSIUN POLRI', 1),
	(2, 18, 'PENERIMA PENSIUN PEJABAT NEGARA', 1),
	(2, 19, 'PERINTIS KEMERDEKAAN', 1),
	(2, 20, 'VETERAN', 1),
	(2, 21, 'PBI (APBN)', 1),
	(2, 22, 'PBI (APBD)', 1),
	(2, 23, 'INVESTOR', 1),
	(2, 24, 'PEMBERI KERJA', 1),
	(2, 25, 'PENERIMA PENSIUN SWASTA', 1),
	(2, 26, 'PNS MABES DAN KEMHAN', 1),
	(2, 27, 'DEWAN PERWAKILAN RAKYAT DAERAH', 1),
	(2, 28, 'KEPALA DESA DAN PERANGKAT DESA', 1);
/*!40000 ALTER TABLE `jenis_peserta_penjamin` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
