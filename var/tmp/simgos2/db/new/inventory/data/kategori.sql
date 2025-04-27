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

-- Membuang data untuk tabel inventory.kategori: ~43 rows (lebih kurang)
/*!40000 ALTER TABLE `kategori` DISABLE KEYS */;
REPLACE INTO `kategori` (`ID`, `NAMA`, `JENIS`, `TANGGAL`, `OLEH`, `STATUS`) VALUES
	('1', 'Farmasi', 1, '2015-09-16 14:28:11', NULL, 1),
	('100', 'Semua Jenis', 2, '2016-08-03 11:50:01', NULL, 1),
	('101', 'Obat', 2, '2015-09-16 14:28:11', NULL, 1),
	('10100', 'Semua Kategori', 3, '2016-08-03 11:50:46', NULL, 1),
	('10101', 'Tablet', 3, '2015-09-16 14:28:11', NULL, 1),
	('10102', 'Injeksi', 3, '2015-09-16 14:28:11', NULL, 1),
	('10103', 'Cairan Infus', 3, '2015-09-16 14:28:11', NULL, 1),
	('10104', 'Syrup', 3, '2015-09-16 14:28:11', NULL, 1),
	('10105', 'Salep', 3, '2015-09-16 14:28:11', NULL, 1),
	('10106', 'Bahan Mata', 3, '2015-09-16 14:28:11', NULL, 1),
	('10107', 'Bahan Gigi', 3, '2015-09-16 14:28:11', NULL, 1),
	('10108', 'Bahan Kimia', 3, '2015-09-16 14:28:11', NULL, 1),
	('10109', 'Narkotika', 3, '2015-09-16 14:28:11', NULL, 1),
	('10110', 'HIV + Avian Flu', 3, '2015-09-16 14:28:11', NULL, 1),
	('10111', 'Bahan Habis Pakai', 3, '2015-09-16 14:28:11', NULL, 1),
	('102', 'Alkes', 2, '2015-09-16 14:28:11', NULL, 1),
	('10201', 'Alat Habis Pakai', 3, '2015-09-16 14:28:11', NULL, 1),
	('10202', 'Pembalut', 3, '2015-09-16 14:28:11', NULL, 1),
	('10203', 'Benang', 3, '2015-09-16 14:28:11', NULL, 1),
	('10204', 'Produksi', 3, '2015-09-16 14:28:11', NULL, 1),
	('10205', 'Produksi Non Steril', 3, '2015-09-16 14:28:11', NULL, 1),
	('10206', 'Bahan Kosmetik', 3, '2015-09-16 14:28:11', NULL, 1),
	('10207', 'Bahan Jantung', 3, '2015-09-16 14:28:11', NULL, 1),
	('103', 'Hemodialisa', 2, '2015-09-16 14:28:11', NULL, 1),
	('10301', 'Bahan Hemodialisa', 3, '2015-09-16 14:28:11', NULL, 1),
	('104', 'Gas Medik', 2, '2015-09-16 14:28:11', NULL, 1),
	('10401', 'Gas Medik', 3, '2015-09-16 14:28:11', NULL, 1),
	('105', 'Laboratorium', 2, '2015-09-16 14:28:11', NULL, 1),
	('10501', 'Bahan Laboratorium', 3, '2015-09-16 14:28:11', NULL, 1),
	('106', 'Radiologi', 2, '2015-09-16 14:28:11', NULL, 1),
	('10601', 'Bahan Radiologi', 3, '2015-09-16 14:28:11', NULL, 1),
	('107', 'Jasa', 2, '2016-05-19 17:04:37', 0, 1),
	('10701', 'Tusla', 3, '2016-05-19 17:04:37', 0, 1),
	('2', 'Non Farmasi', 1, '2015-09-16 14:28:11', NULL, 1),
	('201', 'ATK', 2, '2015-09-16 14:28:11', NULL, 1),
	('20101', 'Alat Tulis', 3, '2015-09-16 14:28:11', NULL, 1),
	('20102', 'Tinta Tulis, Tinta Stempel', 3, '2015-09-16 14:28:11', NULL, 1),
	('202', 'Kertas dan Cover', 2, '2015-09-16 14:28:11', NULL, 1),
	('20201', 'Kertas HVS', 3, '2015-09-16 14:28:11', NULL, 1),
	('20202', 'Amplop', 3, '2015-09-16 14:28:11', NULL, 1),
	('203', 'Lain - Lain', 2, '2016-05-19 16:17:13', 0, 1),
	('20301', 'Eletronik', 3, '2016-05-19 16:43:51', 0, 1),
	('20302', 'Lain - Lain', 3, '2016-05-19 16:46:51', 0, 0);
/*!40000 ALTER TABLE `kategori` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
