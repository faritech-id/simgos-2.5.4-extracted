-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.27 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- membuang struktur untuk table master.template_anatomi
USE master;

CREATE TABLE IF NOT EXISTS `template_anatomi` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KSM` int DEFAULT NULL,
  `NAMA` varchar(50) DEFAULT NULL,
  `TEMPLATE` longblob,
  `TYPE` varchar(20) DEFAULT NULL,
  `ORIENTATION` tinyint DEFAULT '1' COMMENT '1. Portrait, 2. Landscape',
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KSM` (`KSM`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
