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


-- Membuang struktur basisdata untuk document-storage
CREATE DATABASE IF NOT EXISTS `document-storage`;
USE `document-storage`;

-- membuang struktur untuk table document-storage.document
CREATE TABLE IF NOT EXISTS `document` (
  `ID` char(36) NOT NULL,
  `NAME` varchar(150) NOT NULL,
  `EXT` char(5) NOT NULL DEFAULT '',
  `CONTENT_TYPE` varchar(25) NOT NULL DEFAULT '',
  `LOCATION` varchar(1000) NOT NULL,
  `DOCUMENT_DIRECTORY_ID` int NOT NULL,
  `DESCRIPTION` varchar(1000) DEFAULT NULL,
  `CREATED_DATE` datetime NOT NULL,
  `CREATED_BY` varchar(150) NOT NULL,
  `UPDATED_DATE` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(150) DEFAULT NULL,
  `KEY` varchar(100) NOT NULL DEFAULT '',
  `REFERENCE_ID` char(36) NOT NULL,
  `REVISION_FROM` char(36) DEFAULT NULL COMMENT 'DOCUMENT_ID',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
