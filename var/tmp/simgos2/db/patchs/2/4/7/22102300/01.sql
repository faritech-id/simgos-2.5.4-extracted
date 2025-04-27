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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk table layanan.hasil_lab_exam
CREATE TABLE IF NOT EXISTS `hasil_lab_exam` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `DATE_SP1` date DEFAULT NULL,
  `DATE_SP2` date DEFAULT NULL,
  `DATE_SP3` date DEFAULT NULL,
  `ACID_DATE` date DEFAULT NULL,
  `ACID_SP1` varchar(255) DEFAULT NULL,
  `ACID_SP2` varchar(255) DEFAULT NULL,
  `ACID_SP3` varchar(255) DEFAULT NULL,
  `LJ_DATE` date DEFAULT NULL,
  `LJ_SP1` varchar(255) DEFAULT NULL,
  `LJ_SP2` varchar(255) DEFAULT NULL,
  `LJ_SP3` varchar(255) DEFAULT NULL,
  `MGIT_DATE` date DEFAULT NULL,
  `MGIT_SP1` varchar(255) DEFAULT NULL,
  `MGIT_SP2` varchar(255) DEFAULT NULL,
  `MGIT_SP3` varchar(255) DEFAULT NULL,
  `ANTITUBE` varchar(255) DEFAULT NULL,
  `CONCLUSION` varchar(255) DEFAULT NULL,
  `DOKTER` int DEFAULT NULL,
  `OLEH` int DEFAULT NULL,
  `TIMESTAMP` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `STATUS` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `KUNJUNGAN_KEY` (`KUNJUNGAN`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
