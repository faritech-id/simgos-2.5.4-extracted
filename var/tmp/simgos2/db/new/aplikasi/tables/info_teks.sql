-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk table aplikasi.info_teks
DROP TABLE IF EXISTS `info_teks`;
CREATE TABLE IF NOT EXISTS `info_teks` (
  `ID` tinyint(4) NOT NULL AUTO_INCREMENT,
  `JENIS` TINYINT(4) NOT NULL DEFAULT '1',
  `TEKS` text NOT NULL,
  `WARNA` CHAR(10) NOT NULL DEFAULT '',
  `PUBLISH` TINYINT NOT NULL DEFAULT 1,
  `TANGGAL` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `OLEH` SMALLINT NOT NULL,
  `STATUS` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `JENIS` (`JENIS`),
  KEY `PUBLISH` (`PUBLISH`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
