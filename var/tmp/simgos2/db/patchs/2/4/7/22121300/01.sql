-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.31 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping database structure for master
USE `master`;

-- Dumping structure for table master.group_pemeriksaan
CREATE TABLE IF NOT EXISTS `group_pemeriksaan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint NOT NULL COMMENT 'REF#74',
  `KODE` char(4) NOT NULL,
  `LEVEL` tinyint NOT NULL DEFAULT '1',
  `DESKRIPSI` varchar(100) NOT NULL,
  `REF_ID` varchar(35) NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `JENIS_KODE_LEVEL` (`JENIS`,`KODE`,`LEVEL`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
