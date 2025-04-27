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
USE `kemkes-ihs`;
-- Dumping structure for table kemkes-ihs.tindakan_to_loinc
CREATE TABLE IF NOT EXISTS `tindakan_to_loinc` (
  `TINDAKAN` int NOT NULL COMMENT 'ID tindakan',
  `LOINC_TERMINOLOGI` int NOT NULL COMMENT 'loinc_terminologi id',
  `SPESIMENT` smallint NOT NULL DEFAULT '0' COMMENT 'type_code_reference type = 52',
  `KATEGORI` smallint NOT NULL DEFAULT '0' COMMENT 'type_code_reference type = 58',
  `STATUS` tinyint NOT NULL DEFAULT '1' COMMENT 'status',
  PRIMARY KEY (`TINDAKAN`),
  UNIQUE KEY `TINDAKAN_LOINC_TERMINOLOGI` (`TINDAKAN`,`LOINC_TERMINOLOGI`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
