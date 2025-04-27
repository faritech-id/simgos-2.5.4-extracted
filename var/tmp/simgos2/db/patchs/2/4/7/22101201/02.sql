-- --------------------------------------------------------
-- Host:                         192.168.137.8
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


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk table laporan.request_report
CREATE TABLE IF NOT EXISTS `request_report` (
  `ID` char(36) NOT NULL,
  `DOCUMENT_STORAGE_ID` char(36) NOT NULL DEFAULT '',
  `KEY` varchar(100) NOT NULL DEFAULT '',
  `REQUEST_DATA` text NOT NULL,
  `DOCUMENT_DIRECTORY_ID` int NOT NULL,
  `REF_ID` char(36) NOT NULL DEFAULT '',
  `DIBUAT_TANGGAL` datetime NOT NULL,
  `DIBUAT_OLEH` smallint NOT NULL,
  `DIUBAH_TANGGAL` datetime DEFAULT NULL,
  `DIUBAH_OLEH` smallint DEFAULT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `REF_ID` (`REF_ID`),
  KEY `KEY` (`KEY`),
  KEY `DOCUMENT_STORAGE_ID` (`DOCUMENT_STORAGE_ID`),
  KEY `STATUS` (`STATUS`),
  KEY `REPORT_ID` (`DOCUMENT_DIRECTORY_ID`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
