-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
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

-- Dumping structure for table medicalrecord.penilaian_ballance_cairan
CREATE TABLE IF NOT EXISTS `penilaian_ballance_cairan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL COMMENT 'db pendaftaran table kunjungan field NOMOR',
  `INTAKE_ORAL` decimal(10,2) NOT NULL,
  `INTAKE_NGT` decimal(10,2) NOT NULL,
  `TRANSFUSI_PRODUK` varchar(300) NOT NULL,
  `TRANSFUSI_PRODUK_JUMLAH` decimal(10,2) NOT NULL,
  `OUTPUT_ORAL` decimal(10,2) NOT NULL,
  `OUTPUT_NGT` decimal(10,2) DEFAULT NULL,
  `URINE_WARNAH` smallint NOT NULL COMMENT 'Referensi',
  `URINE_JUMLAH` decimal(10,2) NOT NULL,
  `SPOOLING_CATHETER` tinyint NOT NULL DEFAULT '0' COMMENT 'Kan berubah jika tercetang di form',
  `CAIRAN_URINE` decimal(10,2) NOT NULL,
  `CAIRAN_SPOOLING` decimal(10,2) NOT NULL,
  `FASES_TESKTUR` smallint NOT NULL COMMENT 'Referensi',
  `FASES_WARNAH` smallint NOT NULL COMMENT 'Referensi',
  `FASES_JUMLAH` decimal(10,2) NOT NULL,
  `ULTRAFILTRASI` decimal(10,2) NOT NULL,
  `IWL_SUHU_NORMAL` decimal(10,2) NOT NULL,
  `IWL_KENAIKAN_SUHU` decimal(10,2) NOT NULL,
  `TOTAL_INTAKE` decimal(10,2) NOT NULL,
  `TOTAL_OUTPUT` decimal(10,2) NOT NULL,
  `SKOR_BALLANCER_CAIRAN` decimal(10,2) NOT NULL,
  `WAKTU_PEMERIKSAAN` datetime NOT NULL COMMENT 'Waktu pemeriksaan dilakukan',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT '0' COMMENT 'db aplikasi table pengguna field ID',
  `STATUS` tinyint NOT NULL DEFAULT '1' COMMENT 'Status pemmeriksaan 1 aktif 0 tidak aktif',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`,`STATUS`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
