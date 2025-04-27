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

-- membuang struktur untuk table inacbg.list_procedure
DROP TABLE IF EXISTS `list_procedure`;
CREATE TABLE IF NOT EXISTS `list_procedure` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint(4) NOT NULL COMMENT '1=Rawat Inap, 2=Rawat Jalan/Darurat',
  `PROC` char(10) NOT NULL,
  `CMG` char(5) NOT NULL,
  `GROUP_CODE` enum('sprosthesis','sinvestigation','sprocedure') NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `JENIS` (`JENIS`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
