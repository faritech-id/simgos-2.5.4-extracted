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

-- Dumping structure for table medicalrecord.mapping_intervensi_indikator
CREATE TABLE IF NOT EXISTS `mapping_intervensi_indikator` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS` smallint NOT NULL DEFAULT '0',
  `INDIKATOR` int NOT NULL DEFAULT '0',
  `INTERVENSI` int NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `JENIS` (`JENIS`) USING BTREE,
  KEY `INDIKATOR` (`INDIKATOR`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `DIAGNOSA` (`INTERVENSI`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.mapping_intervensi_indikator: ~0 rows (approximately)
/*!40000 ALTER TABLE `mapping_intervensi_indikator` DISABLE KEYS */;
INSERT INTO `mapping_intervensi_indikator` (`ID`, `JENIS`, `INDIKATOR`, `INTERVENSI`, `STATUS`) VALUES
	(2, 6, 1, 1, 1),
	(3, 6, 2, 1, 1),
	(4, 6, 3, 1, 1),
	(5, 6, 4, 2, 1),
	(6, 6, 5, 2, 1),
	(7, 6, 6, 2, 1),
	(8, 6, 7, 2, 1),
	(9, 6, 8, 2, 1),
	(10, 6, 9, 2, 1),
	(11, 6, 10, 2, 1),
	(12, 6, 11, 3, 1),
	(13, 6, 12, 3, 1),
	(14, 6, 13, 3, 1),
	(15, 6, 14, 3, 1),
	(16, 6, 15, 3, 1),
	(17, 6, 16, 3, 1),
	(18, 6, 17, 3, 1),
	(20, 7, 1, 1, 1),
	(21, 7, 2, 1, 1),
	(22, 7, 3, 1, 1),
	(23, 7, 4, 1, 1),
	(24, 7, 5, 1, 1),
	(25, 7, 6, 1, 1),
	(26, 7, 7, 1, 1),
	(27, 7, 8, 1, 1),
	(28, 7, 9, 1, 1),
	(29, 7, 10, 1, 1),
	(30, 7, 11, 1, 1),
	(31, 7, 12, 1, 1),
	(32, 7, 13, 1, 1),
	(33, 7, 14, 1, 1),
	(34, 7, 15, 1, 1),
	(35, 7, 16, 1, 1),
	(36, 7, 17, 2, 1),
	(37, 7, 18, 2, 1),
	(38, 7, 19, 3, 1),
	(39, 7, 20, 3, 1),
	(40, 7, 21, 3, 1),
	(41, 7, 22, 3, 1),
	(42, 7, 23, 3, 1),
	(44, 8, 1, 1, 1),
	(45, 8, 2, 1, 1),
	(46, 8, 3, 2, 1),
	(47, 9, 1, 1, 1);
/*!40000 ALTER TABLE `mapping_intervensi_indikator` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
