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


-- Membuang struktur basisdata untuk master
CREATE DATABASE IF NOT EXISTS `master`;
USE `master`;

-- membuang struktur untuk table master.kartu_identitas_keluarga
CREATE TABLE IF NOT EXISTS `kartu_identitas_keluarga` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint NOT NULL,
  `KELUARGA_PASIEN_ID` int NOT NULL,
  `NOMOR` varchar(16) NOT NULL,
  `ALAMAT` varchar(150) NOT NULL,
  `RT` char(3) DEFAULT NULL,
  `RW` char(3) DEFAULT NULL,
  `KODEPOS` char(5) DEFAULT NULL,
  `WILAYAH` char(10) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `JENIS_KELUARGA_PASIEN_ID` (`JENIS`,`KELUARGA_PASIEN_ID`) USING BTREE,
  KEY `NOMOR` (`NOMOR`)
) ENGINE=InnoDB COMMENT='Kartu Identitas Keluarga';

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
