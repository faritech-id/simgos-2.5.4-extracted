USE `master`;
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

-- Dumping structure for table master.depo_layanan_farmasi
CREATE TABLE IF NOT EXISTS `depo_layanan_farmasi` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `RUANGAN_FARMASI` char(12) NOT NULL COMMENT 'Unit / Depo / Apotek Yang Melayani',
  `RUANGAN_LAYANAN` char(12) NOT NULL COMMENT 'Unit Kunjungan Pasien',
  `MULAI` time NOT NULL DEFAULT '00:00:01',
  `SELESAI` time NOT NULL DEFAULT '23:59:59',
  `STATUS` tinyint DEFAULT '1',
  `OLEH` smallint DEFAULT NULL,
  `INPUT_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UPDATE_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `RUANGAN_FARMASI` (`RUANGAN_FARMASI`),
  KEY `RUANGAN_LAYANAN` (`RUANGAN_LAYANAN`),
  KEY `STATUS` (`STATUS`),
  KEY `MULAI` (`MULAI`),
  KEY `SELESAI` (`SELESAI`)
) ENGINE=InnoDB;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;