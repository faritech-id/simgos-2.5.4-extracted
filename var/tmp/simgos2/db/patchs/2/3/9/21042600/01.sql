-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.33 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk table master.penjamin_sub_spesialistik
CREATE TABLE IF NOT EXISTS `penjamin_sub_spesialistik` (
  `ID` smallint NOT NULL AUTO_INCREMENT,
  `PENJAMIN` smallint NOT NULL,
  `SUB_SPESIALIS_PENJAMIN` char(10) NOT NULL,
  `SUB_SPESIALIS_RS` smallint NOT NULL COMMENT 'REF 26',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `PENJAMIN` (`PENJAMIN`),
  KEY `SUB_SPESIALIS_PENJAMIN` (`SUB_SPESIALIS_PENJAMIN`),
  KEY `SUB_SPESIALIS_RS` (`SUB_SPESIALIS_RS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
