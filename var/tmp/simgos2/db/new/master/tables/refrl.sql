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

-- membuang struktur untuk table master.refrl
DROP TABLE IF EXISTS `refrl`;
CREATE TABLE IF NOT EXISTS `refrl` (
  `JENISRL` char(6) NOT NULL DEFAULT '0',
  `IDJENISRL` tinyint(4) NOT NULL DEFAULT '0',
  `ID` int(4) NOT NULL AUTO_INCREMENT,
  `DESKRIPSI` varchar(150) NOT NULL,
  `KODE` char(8) NOT NULL,
  `KODE_HIRARKI` char(8) NOT NULL,
  `NODAFTAR` varchar(200) NOT NULL,
  PRIMARY KEY (`JENISRL`,`IDJENISRL`,`ID`),
  KEY `KODE` (`KODE`),
  KEY `KODE_HIRARKI` (`KODE_HIRARKI`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
