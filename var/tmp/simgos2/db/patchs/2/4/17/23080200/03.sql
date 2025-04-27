-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `medicalrecord`;

-- Dumping structure for table medicalrecord.rekonsiliasi_admisi
CREATE TABLE IF NOT EXISTS `rekonsiliasi_admisi` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `PENDAFTARAN` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE KEY `KUNJUNGAN_PENDAFTARAN` (`KUNJUNGAN`,`PENDAFTARAN`) USING BTREE,
  KEY `KUNJUNGAN` (`KUNJUNGAN`) USING BTREE,
  KEY `PENDAFTARAN` (`PENDAFTARAN`) USING BTREE,
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.