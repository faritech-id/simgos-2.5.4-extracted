-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.33 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.riwayat_gynekologi
CREATE TABLE IF NOT EXISTS `riwayat_gynekologi` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL COMMENT 'NOMOR KUNJUNGAN',
  `INFERTILITAS` tinyint NOT NULL DEFAULT '0',
  `INFEKSI_VIRUS` tinyint NOT NULL DEFAULT '0',
  `PENYAKIT_MENULAR_SEKSUAL` tinyint NOT NULL DEFAULT '0',
  `CERVISITIS_CRONIS` tinyint NOT NULL DEFAULT '0',
  `ENDOMETRIOSIS` tinyint NOT NULL DEFAULT '0',
  `MYOMA` tinyint NOT NULL DEFAULT '0',
  `POLIP_SERVIX` tinyint NOT NULL DEFAULT '0',
  `KANKER_KANDUNGAN` tinyint NOT NULL DEFAULT '0',
  `MINUMAN_ALKOHOL` tinyint NOT NULL DEFAULT '0',
  `PERKOSAAN` tinyint NOT NULL DEFAULT '0',
  `OPERASI_KANDUNGAN` tinyint NOT NULL DEFAULT '0',
  `POST_COINTAL_BLEEDING` tinyint NOT NULL DEFAULT '0',
  `FLOUR_ALBUS` tinyint NOT NULL DEFAULT '0',
  `LAINYA` tinyint NOT NULL DEFAULT '0',
  `KETERANGAN_LAINNYA` text NOT NULL,
  `GATAL` tinyint NOT NULL DEFAULT '0' COMMENT '1:YA, 2:TIDAK',
  `BERBAU` tinyint NOT NULL DEFAULT '0' COMMENT '1:YA, 2:TIDAK',
  `WARNAH` text NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.riwayat_gynekologi: ~0 rows (approximately)
/*!40000 ALTER TABLE `riwayat_gynekologi` DISABLE KEYS */;
/*!40000 ALTER TABLE `riwayat_gynekologi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
