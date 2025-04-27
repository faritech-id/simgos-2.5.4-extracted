-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.30 - MySQL Community Server - GPL
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

-- Dumping structure for table medicalrecord.faktor_risiko
CREATE TABLE IF NOT EXISTS `faktor_risiko` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) DEFAULT NULL,
  `HIPERTENSI` tinyint DEFAULT '0',
  `DIABETES_MELITUS` tinyint DEFAULT '0',
  `PENYAKIT_JANTUNG` tinyint DEFAULT '0',
  `ASMA` tinyint DEFAULT '0',
  `STROKE` tinyint DEFAULT '0',
  `LIVER` tinyint DEFAULT '0',
  `GINJAL` tinyint DEFAULT '0',
  `TUBERCULOSIS_PARU` tinyint DEFAULT '0',
  `ROKOK` tinyint DEFAULT '0',
  `MINUM_ALKOHOL` tinyint DEFAULT '0',
  `LAIN_LAIN` varchar(100) DEFAULT NULL,
  `PERNAH_DIRAWAT_TIDAK` tinyint DEFAULT '0',
  `PERNAH_DIRAWAT_YA` tinyint DEFAULT '0',
  `PERNAH_DIRAWAT_KAPAN` date DEFAULT NULL,
  `PERNAH_DIRAWAT_DIMANA` varchar(100) DEFAULT NULL,
  `PERNAH_DIRAWAT_DIAGNOSIS` varchar(100) DEFAULT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
