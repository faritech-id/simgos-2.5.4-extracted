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


-- Dumping database structure for kemkes-ihs
USE `kemkes-ihs`;

-- Dumping structure for table kemkes-ihs.rute_obat
CREATE TABLE IF NOT EXISTS `rute_obat` (
  `RUTE` int NOT NULL COMMENT 'master.referensi jenis 217',
  `CODE` int DEFAULT NULL COMMENT 'kemkes_ihs.type_code_reference type = 29',
  PRIMARY KEY (`RUTE`),
  KEY `CODE` (`CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table kemkes-ihs.rute_obat: ~0 rows (approximately)
/*!40000 ALTER TABLE `rute_obat` DISABLE KEYS */;
INSERT INTO `rute_obat` (`RUTE`, `CODE`) VALUES
	(3, 7),
	(1, 5),
	(2, 6),
	(4, 56);
/*!40000 ALTER TABLE `rute_obat` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
