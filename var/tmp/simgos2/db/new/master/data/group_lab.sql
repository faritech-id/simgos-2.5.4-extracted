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

-- Membuang data untuk tabel master.group_lab: ~36 rows (lebih kurang)
/*!40000 ALTER TABLE `group_lab` DISABLE KEYS */;
REPLACE INTO `group_lab` (`ID`, `JENIS`, `DESKRIPSI`, `STATUS`) VALUES
	('10', 1, 'HEMATOLOGI', 1),
	('1001', 2, 'Hematologi Rutin', 1),
	('1002', 2, 'Anemia', 1),
	('1003', 2, 'Koagulasi', 1),
	('1004', 2, 'Hematologi Lain', 1),
	('1005', 2, 'Tes Ical', 1),
	('11', 1, 'KIMIA DARAH', 1),
	('1101', 2, 'Glukosa', 1),
	('1102', 2, 'Fungsi Ginjal', 1),
	('1103', 2, 'Fungsi Hati', 1),
	('1104', 2, 'Fraksi Lipid', 1),
	('1105', 2, 'Penanda Jantung', 1),
	('1106', 2, 'Elektrolit', 1),
	('1107', 2, 'Analisa Gas Darah', 1),
	('1108', 2, 'Kimia Lain', 1),
	('12', 1, 'KIMIA RUTIN', 1),
	('1201', 2, 'Analisa Cairan', 1),
	('13', 1, 'URINALISA', 1),
	('1301', 2, 'Urinalysa', 1),
	('14', 1, 'IMUNOSEROLOGI', 1),
	('1401', 2, 'Penanda Hepatitis', 1),
	('1402', 2, 'Penanda Infeksi TORCH', 1),
	('1403', 2, 'Penanda Anemia', 1),
	('1404', 2, 'Imunoserologi Lain', 1),
	('1405', 2, 'Fungsi Thyroid', 1),
	('1406', 2, 'Tumor Marker', 1),
	('1407', 2, 'Bone Marker', 1),
	('1408', 2, 'Hormon Lain', 1),
	('1409', 2, 'Penanda Infeksi HIV', 1),
	('15', 1, 'MIKROBIOLOGI', 1),
	('1501', 2, 'Mikrobiologi', 1),
	('16', 1, 'PARASITOLOGI', 1),
	('1601', 2, 'Parasitologi', 1),
	('17', 1, 'PEMERIKSAAN LAIN', 1),
	('1701', 2, 'Tes Narkoba', 1),
	('1702', 2, 'Tes Narkoba Test', 1);
/*!40000 ALTER TABLE `group_lab` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
