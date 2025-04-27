-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.29 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for generator
CREATE DATABASE IF NOT EXISTS `generator`;
USE `generator`;

-- Dumping structure for table generator.no_suratsakit
CREATE TABLE IF NOT EXISTS `no_surat_sakit` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `TAHUN` year NOT NULL,
  `URUT` MEDIUMINT NOT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE KEY `TAHUN_URUT` (`TAHUN`,`URUT`) USING BTREE
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
