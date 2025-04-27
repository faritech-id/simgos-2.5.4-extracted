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

-- Dumping structure for table medicalrecord.mapping_diagnosa_indikator
CREATE TABLE IF NOT EXISTS `mapping_diagnosa_indikator` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS` smallint NOT NULL DEFAULT '0',
  `INDIKATOR` int NOT NULL DEFAULT '0',
  `DIAGNOSA` int NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `JENIS` (`JENIS`),
  KEY `INDIKATOR` (`INDIKATOR`),
  KEY `STATUS` (`STATUS`),
  KEY `DIAGNOSA` (`DIAGNOSA`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.mapping_diagnosa_indikator: ~5 rows (approximately)
/*!40000 ALTER TABLE `mapping_diagnosa_indikator` DISABLE KEYS */;
INSERT INTO `mapping_diagnosa_indikator` (`ID`, `JENIS`, `INDIKATOR`, `DIAGNOSA`, `STATUS`) VALUES
	(1, 1, 1, 1, 1),
	(2, 1, 2, 1, 1),
	(3, 1, 3, 1, 1),
	(4, 1, 4, 2, 1),
	(5, 1, 5, 2, 1),
	(6, 1, 6, 2, 1),
	(7, 1, 7, 3, 1),
	(8, 1, 8, 3, 1),
	(10, 2, 1, 1, 1),
	(11, 2, 2, 1, 1),
	(12, 2, 3, 1, 1),
	(13, 2, 4, 1, 1),
	(14, 2, 5, 1, 1),
	(15, 2, 6, 2, 1),
	(16, 2, 7, 2, 1),
	(17, 2, 8, 2, 1),
	(18, 2, 9, 2, 1),
	(19, 2, 10, 2, 1),
	(20, 2, 11, 2, 1),
	(21, 2, 12, 2, 1),
	(22, 2, 13, 3, 1),
	(23, 2, 14, 3, 1),
	(24, 2, 15, 3, 1),
	(25, 2, 16, 3, 1),
	(26, 2, 17, 3, 1),
	(27, 2, 18, 1, 1),
	(28, 2, 19, 1, 1),
	(29, 2, 20, 1, 1),
	(30, 2, 21, 1, 1),
	(31, 2, 22, 1, 1),
	(32, 2, 23, 2, 1),
	(33, 2, 24, 2, 1),
	(34, 2, 25, 2, 1),
	(35, 2, 26, 2, 1),
	(36, 2, 27, 2, 1),
	(37, 2, 28, 2, 1),
	(38, 2, 29, 2, 1),
	(39, 2, 30, 3, 1),
	(40, 2, 31, 3, 1),
	(41, 2, 32, 3, 1),
	(42, 2, 33, 3, 1),
	(43, 2, 34, 2, 1),
	(44, 2, 34, 3, 1),
	(46, 3, 1, 1, 1),
	(47, 3, 2, 1, 1),
	(48, 3, 3, 1, 1),
	(49, 3, 4, 1, 1),
	(50, 3, 5, 1, 1),
	(51, 3, 6, 1, 1),
	(52, 3, 7, 1, 1),
	(53, 3, 8, 1, 1),
	(54, 3, 9, 1, 1),
	(55, 3, 10, 1, 1),
	(56, 3, 11, 2, 1),
	(57, 3, 12, 2, 1),
	(58, 3, 13, 2, 1),
	(59, 3, 14, 2, 1),
	(60, 3, 15, 2, 1),
	(61, 3, 16, 2, 1),
	(62, 3, 17, 2, 1),
	(63, 3, 18, 3, 1),
	(64, 3, 19, 3, 1),
	(65, 4, 1, 1, 1),
	(66, 4, 2, 3, 1),
	(67, 5, 1, 1, 1),
	(68, 5, 2, 3, 1);
/*!40000 ALTER TABLE `mapping_diagnosa_indikator` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
