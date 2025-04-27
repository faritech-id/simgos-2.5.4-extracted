-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.asuhan_keperawatan
CREATE TABLE IF NOT EXISTS `asuhan_keperawatan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `SUBJECKTIF` json DEFAULT NULL,
  `OBJEKTIF` json DEFAULT NULL,
  `DIAGNOSA` int NOT NULL,
  `PENYEBAP` json DEFAULT NULL,
  `TUJUAN` int NOT NULL,
  `INTERVENSI` int NOT NULL,
  `OBSERVASI` json DEFAULT NULL,
  `THEURAPEUTIC` json DEFAULT NULL,
  `EDUKASI` json DEFAULT NULL,
  `KOLABORASI` json DEFAULT NULL,
  `OLEH` int NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `STATUS` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`),
  KEY `OLEH` (`OLEH`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
