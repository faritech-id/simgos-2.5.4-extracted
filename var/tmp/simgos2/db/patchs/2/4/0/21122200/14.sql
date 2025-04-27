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

-- Membuang struktur basisdata untuk penjamin_rs
USE `penjamin_rs`;

-- membuang struktur untuk table penjamin_rs.drivers
CREATE TABLE IF NOT EXISTS `drivers` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS_DRIVER_ID` smallint NOT NULL,
  `JENIS_PENJAMIN_ID` smallint NOT NULL DEFAULT '0' COMMENT 'REF#10',
  `CLASS` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `JENIS_DRIVER_ID` (`JENIS_DRIVER_ID`),
  KEY `JENIS_PENJAMIN_ID` (`JENIS_PENJAMIN_ID`)
) ENGINE=InnoDB;

-- Membuang data untuk tabel penjamin_rs.drivers: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `drivers` DISABLE KEYS */;
REPLACE INTO `drivers` (`ID`, `JENIS_DRIVER_ID`, `JENIS_PENJAMIN_ID`, `CLASS`) VALUES
	(1, 1, 2, 'plugins.bpjs.pendaftaran.Form');
/*!40000 ALTER TABLE `drivers` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
