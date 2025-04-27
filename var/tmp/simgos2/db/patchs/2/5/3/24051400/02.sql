-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk tte
CREATE DATABASE IF NOT EXISTS `tte` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `tte`;

-- tte.sign definition

CREATE TABLE IF NOT EXISTS `sign` (
  `ID` char(36) NOT NULL,
  `PROVIDER_ID` tinyint NOT NULL DEFAULT '1' COMMENT '1 = BSrE',
  `PROVIDER_REF_ID` char(36) NOT NULL COMMENT 'Dokumen Id',
  `TTD_OLEH` char(16) NOT NULL,
  `TTD_TANGGAL` datetime NOT NULL,
  `REF_ID` char(36) NOT NULL COMMENT 'Id referensi dokumen',
  `REF_JENIS` tinyint NOT NULL DEFAULT '1' COMMENT '1 = Request Report; 2 = Document Storage',
  PRIMARY KEY (`ID`),
  KEY `sign_REF_ID_IDX` (`REF_ID`),
  KEY `sign_REF_JENIS_IDX` (`REF_JENIS`),
  KEY `sign_PROVIDER_ID_IDX` (`PROVIDER_ID`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
