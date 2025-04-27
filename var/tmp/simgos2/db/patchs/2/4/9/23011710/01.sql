-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE inacbg;
-- Dumping structure for table inacbg.no_urut_berkas
CREATE TABLE IF NOT EXISTS `no_urut_berkas` (
  `JENIS` tinyint(1) NOT NULL COMMENT '1=Rawat Inap, 2=Rawat Jalan/Rawat Darurat',
  `TANGGAL` date NOT NULL,
  `KELAS` int(10) NOT NULL,
  `NOMOR` int(10) NOT NULL AUTO_INCREMENT,
  `NOPEN` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `TANGGAL_INPUT` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`JENIS`,`TANGGAL`,`KELAS`,`NOMOR`) USING BTREE,
  KEY `NOPEN` (`NOPEN`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
