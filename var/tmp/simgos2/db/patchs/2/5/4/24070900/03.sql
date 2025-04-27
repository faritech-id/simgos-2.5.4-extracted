-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
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

-- Dumping structure for table medicalrecord.pemeriksaan_observasi_transfusi_darah
CREATE TABLE IF NOT EXISTS `pemeriksaan_observasi_transfusi_darah` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `NOMOR_BAG_DARAH` int NOT NULL DEFAULT (0) COMMENT 'ID TABLE medicalrecord.pemeriksaan_transfusi_darah_detail',
  `REAKSI_LAMBAT` tinyint NOT NULL DEFAULT '0' COMMENT '0 : TIDAK AKTIF, 1 : AKTIF',
  `REAKSI_TRANSFUSI` smallint NOT NULL DEFAULT (0) COMMENT 'ID TABLE master.referensi',
  `PERUBAHAN_KONDISI_PASIEN` text NOT NULL,
  `TTV` int NOT NULL DEFAULT (0) COMMENT 'ID TABLE medicalrecord.tanda_vital',
  `TANGGAL_INPUT` datetime NOT NULL DEFAULT (0),
  `TANGGAL` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT (0),
  `STATUS` tinyint NOT NULL DEFAULT (0) COMMENT '1 : AKTIF, 0 : NONAKTIF',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
