-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk pegawai
USE `pegawai`;

-- membuang struktur untuk table pegawai.str_sip
CREATE TABLE IF NOT EXISTS `str_sip` (
  `ID` smallint NOT NULL AUTO_INCREMENT,
  `NIP` varchar(50) NOT NULL,
  `JENIS` smallint NOT NULL,
  `NOMOR` text NOT NULL,
  `TANGGAL_BERLAKU` date NOT NULL,
  `BERLAKU_SAMPAI` date NOT NULL,
  `FILE` longblob,
  `TYPE` varchar(50) DEFAULT NULL,
  `TANGGAL` date NOT NULL,
  `STATUS` smallint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `NIP` (`NIP`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
