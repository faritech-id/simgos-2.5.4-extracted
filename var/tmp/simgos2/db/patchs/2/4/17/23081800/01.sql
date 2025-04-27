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

-- Dumping structure for table medicalrecord.pemantuan_hd_intradialitik
CREATE TABLE IF NOT EXISTS `pemantuan_hd_intradialitik` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `QUICK_BLOOD` decimal(10,2) NOT NULL DEFAULT '0.00',
  `QUICK_DIALISIS` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ULTRA_FILTRASI_VOLUME` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ULTRA_FILTRASI_RATE` decimal(10,2) NOT NULL DEFAULT '0.00',
  `WAKTU_PEMERIKSAAN` datetime NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.pemantuan_hd_intradialitik: ~0 rows (approximately)
/*!40000 ALTER TABLE `pemantuan_hd_intradialitik` DISABLE KEYS */;
/*!40000 ALTER TABLE `pemantuan_hd_intradialitik` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
