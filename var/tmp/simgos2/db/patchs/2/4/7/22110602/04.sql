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

-- Dumping structure for table kemkes-ihs.barang_to_bza
CREATE TABLE IF NOT EXISTS `barang_to_bza` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `BARANG` int NOT NULL,
  `KODE_BZA` char(10) DEFAULT NULL,
  `DOSIS_KFA` decimal(6,2) NOT NULL DEFAULT '0.00',
  `SATUAN_DOSIS_KFA` smallint NOT NULL DEFAULT '0' COMMENT 'table type_code_reference type = 19',
  `DOSIS_PERSATUAN` decimal(6,2) NOT NULL DEFAULT '0.00',
  `SATUAN` smallint NOT NULL DEFAULT '0' COMMENT 'table type_code_reference type = 19',
  `STATUS` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `STATUS` (`STATUS`),
  KEY `KODE_BZA` (`KODE_BZA`),
  KEY `BARANG` (`BARANG`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
