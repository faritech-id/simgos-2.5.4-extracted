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


-- Membuang struktur basisdata untuk penjamin_rs
USE `penjamin_rs`;

-- membuang struktur untuk table penjamin_rs.kenaikan_tarif
CREATE TABLE IF NOT EXISTS `kenaikan_tarif` (
  `ID` smallint NOT NULL AUTO_INCREMENT,
  `PENJAMIN` smallint NOT NULL COMMENT 'REF#10',
  `JENIS` smallint NOT NULL DEFAULT '3' COMMENT 'REF#30',
  `PERSENTASE` decimal(20,2) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `TANGGAL_SK` datetime DEFAULT NULL,
  `NOMOR_SK` char(35) DEFAULT NULL,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PENJAMIN_JENIS_TANGGAL` (`PENJAMIN`,`JENIS`,`TANGGAL`),
  KEY `STATUS` (`STATUS`),
  KEY `PENJAMIN` (`PENJAMIN`),
  KEY `JENIS` (`JENIS`),
  KEY `TANGGAL` (`TANGGAL`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
