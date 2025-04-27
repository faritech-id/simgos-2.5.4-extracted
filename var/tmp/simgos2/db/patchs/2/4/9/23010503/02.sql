-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk logs
USE `logs`;

-- membuang struktur untuk table logs.pengguna_request_log
CREATE TABLE IF NOT EXISTS `pengguna_request_log` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `PENGGUNA` smallint NOT NULL,
  `TANGGAL_AKSES` datetime NOT NULL,
  `TANGGAL_SELESAI` datetime DEFAULT NULL,
  `LOKASI_AKSES` char(15) NOT NULL,
  `TUJUAN_AKSES` char(15) NOT NULL,
  `REQUEST_URI` varchar(1000) NOT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `PENGGUNA` (`PENGGUNA`) USING BTREE,
  KEY `TANGGAL_AKSES` (`TANGGAL_AKSES`) USING BTREE,
  KEY `LOKASI_AKSES` (`LOKASI_AKSES`) USING BTREE,
  KEY `TUJUAN_AKSES` (`TUJUAN_AKSES`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
