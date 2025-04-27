-- --------------------------------------------------------
-- Host:                         192.168.137.7
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
USE `kemkes-ihs`;

-- Dumping structure for table kemkes-ihs.petunjuk_racikan
CREATE TABLE IF NOT EXISTS `petunjuk_racikan` (
  `ID_REFERENSI` smallint NOT NULL COMMENT 'master referensi jenis = 84',
  `ID_CODING` smallint NOT NULL COMMENT 'type_code_reference type = 15',
  `SATUAN` smallint NOT NULL COMMENT 'table type_code_reference type = 19',
  PRIMARY KEY (`ID_REFERENSI`,`ID_CODING`)
) ENGINE=InnoDB;

-- Dumping data for table kemkes-ihs.petunjuk_racikan: ~3 rows (approximately)
/*!40000 ALTER TABLE `petunjuk_racikan` DISABLE KEYS */;
REPLACE INTO `petunjuk_racikan` (`ID_REFERENSI`, `ID_CODING`, `SATUAN`) VALUES
	(1, 47, 223),
	(2, 66, 205),
	(3, 30, 234);
/*!40000 ALTER TABLE `petunjuk_racikan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
