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


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.penilaian_barthel_index_modifikasi
CREATE TABLE IF NOT EXISTS `penilaian_barthel_index_modifikasi` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) NOT NULL,
  `KESADARAN` tinyint NOT NULL,
  `OBSERVASI_TTV` tinyint NOT NULL,
  `PERNAPASAN` tinyint NOT NULL,
  `KEBERSIHAN_DIRI_DAN_BERPAKAIAN` tinyint NOT NULL,
  `MAKAN_DAN_MINUM` tinyint NOT NULL,
  `PENGOBATAN` tinyint NOT NULL,
  `MOBILISASI` tinyint NOT NULL,
  `ELIMINASI` tinyint NOT NULL,
  `TANGGAL_PENILAIAN` date NOT NULL,
  `SKOR_SEBELUM_SAKIT` int NOT NULL,
  `TANGGAL_DIBUAT` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
