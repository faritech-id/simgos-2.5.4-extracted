-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.27 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk medicalrecord
CREATE DATABASE IF NOT EXISTS `medicalrecord`;
USE `medicalrecord`;

-- membuang struktur untuk table medicalrecord.penanda_gambar_detail
CREATE TABLE IF NOT EXISTS `penanda_gambar_detail` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `PENANDA` int NOT NULL,
  `NOMOR` int NOT NULL,
  `TIPE` int NOT NULL DEFAULT '1' COMMENT '1. Kordinat 2. Free Draw',
  `NAMA_TIPE` varchar(15) DEFAULT NULL,
  `KORDINATX` int DEFAULT NULL,
  `KORDINATY` int DEFAULT NULL,
  `WARNA` varchar(15) DEFAULT NULL,
  `PATH` longtext,
  `WARNA_LATAR` varchar(15) DEFAULT 'none',
  `KETERANGAN` text,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PENANDA_NOMOR` (`PENANDA`,`NOMOR`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
