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

-- Membuang struktur basisdata untuk gambar
CREATE DATABASE IF NOT EXISTS `gambar` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `gambar`;

-- membuang struktur untuk table gambar.photo_pasien
CREATE TABLE IF NOT EXISTS `photo_pasien` (
  `NORM` int(11) NOT NULL,
  `DATA` mediumblob NOT NULL COMMENT 'Photo',
  `TIPE` varchar(15) NOT NULL COMMENT 'Format/Tipe File Gambar',
  PRIMARY KEY (`NORM`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

-- membuang struktur untuk table gambar.photo_pegawai
CREATE TABLE IF NOT EXISTS `photo_pegawai` (
  `NIP` char(30) NOT NULL,
  `DATA` mediumblob NOT NULL COMMENT 'Photo',
  `TIPE` varchar(15) NOT NULL COMMENT 'Format/Tipe File Gambar',
  PRIMARY KEY (`NIP`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
