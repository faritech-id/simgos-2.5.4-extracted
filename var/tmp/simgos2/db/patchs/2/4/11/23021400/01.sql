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


-- Dumping database structure for master
USE `master`;

-- Dumping structure for table master.jenis_nomor_surat
CREATE TABLE IF NOT EXISTS `jenis_nomor_surat` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS_SURAT` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `KODE` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `STATUS` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='jenis kelasifikasi surat';

-- Dumping data for table master.jenis_nomor_surat: ~0 rows (approximately)
/*!40000 ALTER TABLE `jenis_nomor_surat` DISABLE KEYS */;
INSERT INTO `jenis_nomor_surat` (`ID`, `JENIS_SURAT`, `KODE`, `STATUS`) VALUES
	(1, 'Surat Keterangan / Kontrol\r\n', 'YR.01.01', 1),
	(2, 'Surat Rujukan Keluar/Balik\r\n', 'YR.04.02', 1);
/*!40000 ALTER TABLE `jenis_nomor_surat` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
