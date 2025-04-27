-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.28 - MySQL Community Server - GPL
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

-- Dumping structure for table medicalrecord.penilaian_skala_humpty_dumpty
CREATE TABLE IF NOT EXISTS `penilaian_skala_humpty_dumpty` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `UMUR` tinyint NOT NULL COMMENT 'REF#192',
  `JENIS_KELAMIN` tinyint NOT NULL COMMENT 'REF#193',
  `DIAGNOSA` tinyint NOT NULL COMMENT 'REF#194',
  `GANGGUAN_KONGNITIF` tinyint NOT NULL COMMENT 'REF#195',
  `FAKTOR_LINGKUNGAN` tinyint NOT NULL COMMENT 'REF#196',
  `RESPON` tinyint NOT NULL COMMENT 'Terhadap Operasi/Obat Penenang/Efek Anastesi REF#197',
  `PENGGUNAAN_OBAT` tinyint NOT NULL COMMENT 'REF#198',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB COMMENT='Risiko Jatuh';

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
