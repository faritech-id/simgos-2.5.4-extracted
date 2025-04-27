USE `layanan`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table layanan.layanan_bon_sisa_farmasi
CREATE TABLE IF NOT EXISTS `layanan_bon_sisa_farmasi` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `REF` bigint NOT NULL,
  `FARMASI` smallint NOT NULL COMMENT 'Obat Yang Di Layani / Diberikan',
  `JUMLAH` decimal(20,2) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `OLEH` tinyint NOT NULL,
  `STATUS` tinyint DEFAULT '1',
  `INPUT_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UPDATE_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `REF` (`REF`),
  KEY `FARMASI` (`FARMASI`),
  KEY `STATUS` (`STATUS`),
  KEY `TANGGAL` (`TANGGAL`)
) ENGINE=InnoDB;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;