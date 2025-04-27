-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.32 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.penilaian_barthel_index
CREATE TABLE IF NOT EXISTS `penilaian_barthel_index` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `PENDAFTARAN` char(10) NOT NULL,
  `TANGGAL` date NOT NULL,
  `SEBELUM_SAKIT` tinyint NOT NULL DEFAULT '0',
  `KENDALI_RANGSANG_DEFEKASI` tinyint DEFAULT NULL,
  `KENDALI_RANGSANG_KEMIH` tinyint DEFAULT NULL,
  `BERSIH_DIRI` tinyint DEFAULT NULL,
  `PENGGUNAAN_JAMBAN` tinyint DEFAULT NULL,
  `MAKAN` tinyint DEFAULT NULL,
  `PERUBAHAN_SIKAP` tinyint DEFAULT NULL,
  `PINDAH_JALAN` tinyint DEFAULT NULL,
  `PAKAI_BAJU` tinyint DEFAULT NULL,
  `NAIK_TURUN_TANGGA` tinyint DEFAULT NULL,
  `MANDI` tinyint DEFAULT NULL,
  `DIBUAT_TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
