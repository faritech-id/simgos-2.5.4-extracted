-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.32 - MySQL Community Server - GPL
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

-- Dumping structure for table medicalrecord.pemeriksaan_tcd
CREATE TABLE IF NOT EXISTS `pemeriksaan_tcd` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `TEMUAN` tinytext NOT NULL,
  `KESAN` tinytext NOT NULL,
  `USUL` tinytext NOT NULL,
  `DIBUAT_TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
