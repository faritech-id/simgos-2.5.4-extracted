-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk table pembayaran.layanan_penyedia
CREATE TABLE IF NOT EXISTS `layanan_penyedia` (
  `ID` smallint NOT NULL AUTO_INCREMENT,
  `PENYEDIA_ID` smallint NOT NULL,
  `JENIS_LAYANAN_ID` tinyint NOT NULL DEFAULT '0' COMMENT 'REF#172',
  `DRIVER` varchar(100) NOT NULL DEFAULT '',
  `KODE` char(10) DEFAULT NULL,
  `STATUS_ID` tinyint DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `PENYEDIA_ID` (`PENYEDIA_ID`),
  KEY `JENIS_LAYANAN_ID` (`JENIS_LAYANAN_ID`),
  KEY `STATUS_ID` (`STATUS_ID`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
