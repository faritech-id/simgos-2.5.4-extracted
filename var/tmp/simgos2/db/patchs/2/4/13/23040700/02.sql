-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `medicalrecord`;

-- Dumping structure for table medicalrecord.discharge_planning_skrining
CREATE TABLE IF NOT EXISTS `discharge_planning_skrining` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) DEFAULT NULL,
  `KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB` tinyint DEFAULT '0',
  `KPB_RAWAT_LUKA` tinyint DEFAULT '0',
  `KPB_HIV` tinyint DEFAULT '0',
  `KPB_TB` tinyint DEFAULT '0',
  `KPB_DM` tinyint DEFAULT '0',
  `KPB_DM_TERAPI_INSULIN` tinyint DEFAULT '0',
  `KPB_STROKE` tinyint DEFAULT '0',
  `KPB_PPOK` tinyint DEFAULT '0',
  `KPB_CKD` tinyint DEFAULT '0',
  `KPB_PASIEN_KEMO` tinyint DEFAULT '0',
  `PENGGUNAAN_ALAT_MEDIS_PAM` tinyint DEFAULT '0',
  `PAM_KATETER_URIN` tinyint DEFAULT '0',
  `PAM_NGT` tinyint DEFAULT '0',
  `PAM_TRAECHOSTOMY` tinyint DEFAULT '0',
  `PAM_COLOSTOMY` tinyint DEFAULT '0',
  `PAM_LAINNYA` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
