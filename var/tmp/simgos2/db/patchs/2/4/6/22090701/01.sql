-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Server version:               5.7.36 - MySQL Community Server (GPL)
-- Server OS:                    Linux
-- HeidiSQL Version:             12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `layanan`;

-- Dumping structure for table layanan.hasil_lab_kultur
CREATE TABLE IF NOT EXISTS `hasil_lab_kultur` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `BAHAN` varchar(50) DEFAULT NULL,
  `GRAM` varchar(200) DEFAULT NULL,
  `AEROB` varchar(200) DEFAULT NULL,
  `KESIMPULAN` varchar(200) DEFAULT NULL,
  `ANJURAN` varchar(200) DEFAULT NULL,
  `CATATAN` varchar(200) DEFAULT NULL,
  `TGL_HASIL` datetime DEFAULT NULL,
  `DOKTER` smallint DEFAULT NULL,
  `OLEH` smallint DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN_UNIQE` (`KUNJUNGAN`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `DOKTER` (`DOKTER`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

-- Dumping structure for table layanan.hasil_lab_kepekaan
CREATE TABLE IF NOT EXISTS `hasil_lab_kepekaan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) DEFAULT NULL,
  `BAKTERI` smallint DEFAULT NULL COMMENT 'REF#129',
  `ANTIBIOTIK` smallint DEFAULT NULL COMMENT 'REF#128',
  `HASIL` varchar(50) DEFAULT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `BAKTERI` (`BAKTERI`),
  KEY `ANTIBIOTIK` (`ANTIBIOTIK`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
