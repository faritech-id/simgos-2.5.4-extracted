-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.36 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for layanan
USE `layanan`;

-- Dumping structure for table layanan.permintaan_darah_detail
CREATE TABLE IF NOT EXISTS `permintaan_darah_detail` (
  `NOMOR` char(50) NOT NULL,
  `ORDER_ID` char(21) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `KOMPONEN` tinyint NOT NULL,
  `QTY` smallint NOT NULL,
  `DIBUAT_TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`NOMOR`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `ORDER_ID` (`ORDER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
