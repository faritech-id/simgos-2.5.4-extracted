-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.35 - MySQL Community Server - GPL
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

USE `berkas_klaim`;

-- Dumping structure for table berkas_klaim.dokumen_pendukung
CREATE TABLE IF NOT EXISTS `dokumen_pendukung` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `BERKAS` int NOT NULL,
  `DESKRIPSI` text,
  `DOKUMEN_PENDUKUNG` char(36) DEFAULT NULL,
  `TANGGAL` datetime DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `BERKAS` (`BERKAS`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
