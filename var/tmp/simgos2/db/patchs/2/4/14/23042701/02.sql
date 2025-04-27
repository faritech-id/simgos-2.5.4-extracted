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

-- Dumping structure for table medicalrecord.diagnosa_keperawatan
CREATE TABLE IF NOT EXISTS `diagnosa_keperawatan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KODE` varchar(20) NOT NULL,
  `DESKRIPSI` varchar(350) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `KODE` (`KODE`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.diagnosa_keperawatan: ~0 rows (approximately)
/*!40000 ALTER TABLE `diagnosa_keperawatan` DISABLE KEYS */;
INSERT INTO `diagnosa_keperawatan` (`ID`, `KODE`, `DESKRIPSI`, `STATUS`) VALUES
	(1, 'D.0001', 'Bersihan Jalan Napas Tidak Efektif.', 1),
	(2, 'D.0002', 'Gangguan Penyapihan Ventilator', 1),
	(3, 'D.0003 ', 'Gangguan Pertukaran Gas', 1);
/*!40000 ALTER TABLE `diagnosa_keperawatan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
