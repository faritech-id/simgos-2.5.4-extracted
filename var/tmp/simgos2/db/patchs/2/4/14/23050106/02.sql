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

-- Dumping structure for table medicalrecord.penilaian_getup_and_go
CREATE TABLE IF NOT EXISTS `penilaian_getup_and_go` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `CARA_BERJALAN_PASIEN` tinyint NOT NULL,
  `FAKTOR_RESIKO` tinyint NOT NULL,
  `OBAT_YANG_DIMINUM` tinyint NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Risiko Jatuh';

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
