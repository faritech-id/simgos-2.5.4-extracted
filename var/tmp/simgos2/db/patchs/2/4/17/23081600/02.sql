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

-- Dumping structure for table medicalrecord.rekonsiliasi_discharge_detil
CREATE TABLE IF NOT EXISTS `rekonsiliasi_discharge_detil` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `REKONSILIASI_DISCHARGE` int NOT NULL,
  `OBAT_DARI_LUAR` varchar(200) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `DOSIS` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `FREKUENSI` int NOT NULL,
  `RUTE` int NOT NULL,
  `TINDAK_LANJUT` int NOT NULL,
  `PERUBAHAN_ATURAN_PAKAI` int NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  `INPUT_ASAL` tinyint NOT NULL COMMENT '1: Rekonsiliasi Admisi; 2: Rekonsiliasi Transfer; 3: Layanan Farmasi Depo Terakhir;',
  `REKONSILIASI_ADMISI_DETIL` int NOT NULL,
  `REKONSILIASI_TRANSFER_DETIL` int NOT NULL,
  `LAYANAN_FARMASI` char(11) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `FREKUENSI` (`FREKUENSI`) USING BTREE,
  KEY `RUTE` (`RUTE`) USING BTREE,
  KEY `TINDAK_LANJUT` (`TINDAK_LANJUT`) USING BTREE,
  KEY `PERUBAHAN_ATURAN_PAKAI` (`PERUBAHAN_ATURAN_PAKAI`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `REKONSILIASI_DISCHARGE` (`REKONSILIASI_DISCHARGE`) USING BTREE,
  KEY `REKONSILIASI_ADMISI_DETIL` (`REKONSILIASI_ADMISI_DETIL`) USING BTREE,
  KEY `REKONSILIASI_TRANSFER_DETIL` (`REKONSILIASI_TRANSFER_DETIL`) USING BTREE,
  KEY `OBAT_DARI_LUAR` (`OBAT_DARI_LUAR`) USING BTREE,
  KEY `LAYANAN_FARMASI` (`LAYANAN_FARMASI`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.rekonsiliasi_discharge_detil: ~0 rows (approximately)
/*!40000 ALTER TABLE `rekonsiliasi_discharge_detil` DISABLE KEYS */;
/*!40000 ALTER TABLE `rekonsiliasi_discharge_detil` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
