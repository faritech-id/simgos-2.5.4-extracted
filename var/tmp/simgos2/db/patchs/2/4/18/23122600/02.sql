-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
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

-- Dumping structure for table medicalrecord.pemeriksaan_saluran_cernah_atas
CREATE TABLE IF NOT EXISTS `pemeriksaan_saluran_cernah_atas` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `ADA_KELAINAN` tinyint NOT NULL,
  `DARAH_SEGAR` tinyint NOT NULL DEFAULT '0',
  `HITAM` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `LENDIR` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `CAIR` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `BIASA` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `FREKUENSI` smallint NOT NULL DEFAULT '0' COMMENT 'DALAM HITUNGAN HARI',
  `TERATUR` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `KONSTIPASI` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `BAU_BUSUK_TINJA` tinyint NOT NULL DEFAULT '0' COMMENT '0. TIDAK, 1. YA',
  `BENTUK_TINJA` tinyint NOT NULL DEFAULT '0' COMMENT '0. BIASA, 1. MENYERUPAI KOTORAN KAMBING',
  `KENCING` tinyint NOT NULL DEFAULT '1' COMMENT '0. TIDAK LANCAR, 1. LANCAR',
  `DESKRIPSI` text NOT NULL,
  `TANGGAL` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '1' COMMENT '0. TIDAK, 1. AKTIF',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
