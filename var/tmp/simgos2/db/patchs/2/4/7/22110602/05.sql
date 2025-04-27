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

-- Dumping structure for table kemkes-ihs.barang_to_poa_pov
CREATE TABLE IF NOT EXISTS `barang_to_poa_pov` (
  `BARANG` int NOT NULL,
  `KODE_POA` char(10) DEFAULT NULL,
  `KODE_POV` char(10) DEFAULT NULL,
  `RUTE_OBAT` smallint NOT NULL COMMENT 'type_code_reference type = 29',
  `STATUS` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`BARANG`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `KODE_POV` (`KODE_POV`),
  KEY `KODE_POA` (`KODE_POA`)
) ENGINE=InnoDB COMMENT='Untuk menyimpan mapping barang ihs POA dan POV dengan kode barang yang ada di SIMRS';

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
