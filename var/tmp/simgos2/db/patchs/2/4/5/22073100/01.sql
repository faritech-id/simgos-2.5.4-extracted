-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pendaftaran
CREATE DATABASE IF NOT EXISTS `pendaftaran`;
USE `pendaftaran`;

-- Dumping structure for table pendaftaran.kartu_identitas_pengantar_pasien
CREATE TABLE `kartu_identitas_pengantar_pasien` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`JENIS` TINYINT NOT NULL,
	`PENGANTAR_ID` INT NOT NULL,
	`NOMOR` VARCHAR(16) NOT NULL,
	`ALAMAT` VARCHAR(150) NOT NULL,
	`RT` CHAR(3) NULL DEFAULT NULL,
	`RW` CHAR(3) NULL DEFAULT NULL,
	`KODEPOS` CHAR(5) NULL DEFAULT NULL,
	`WILAYAH` CHAR(10) NOT NULL,
	PRIMARY KEY (`ID`) USING BTREE,
	UNIQUE INDEX `JENIS_PENGANTAR_ID` (`JENIS`, `PENGANTAR_ID`) USING BTREE,
	INDEX `NOMOR` (`NOMOR`) USING BTREE
)
ENGINE=InnoDB;

-- Data exporting was unselected.

-- Dumping structure for table pendaftaran.kontak_pengantar_pasien
CREATE TABLE IF NOT EXISTS `kontak_pengantar_pasien` (
  `JENIS` tinyint NOT NULL,
  `ID` int NOT NULL,
  `NOMOR` varchar(35) NOT NULL,
  PRIMARY KEY (`JENIS`,`ID`,`NOMOR`) USING BTREE
) ENGINE=InnoDB;

-- Data exporting was unselected.

-- Dumping structure for table pendaftaran.pengantar_pasien
CREATE TABLE IF NOT EXISTS `pengantar_pasien` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `NOPEN` char(10) NOT NULL,
  `REF` tinyint DEFAULT NULL,
  `SHDK` tinyint NOT NULL,
  `JENIS_KELAMIN` tinyint NOT NULL DEFAULT '1',
  `NAMA` varchar(75) NOT NULL,
  `ALAMAT` varchar(150) DEFAULT NULL,
  `PENDIDIKAN` tinyint DEFAULT NULL,
  `PEKERJAAN` tinyint DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `NOPEN` (`NOPEN`) USING BTREE,
  KEY `REF` (`REF`) USING BTREE,
  KEY `SHDK` (`SHDK`) USING BTREE,
  KEY `JENIS_KELAMIN` (`JENIS_KELAMIN`) USING BTREE,
  KEY `NAMA` (`NAMA`) USING BTREE
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
