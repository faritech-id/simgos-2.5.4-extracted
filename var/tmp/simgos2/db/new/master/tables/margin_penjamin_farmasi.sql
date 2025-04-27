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

-- membuang struktur untuk table master.margin_penjamin_farmasi
DROP TABLE IF EXISTS `margin_penjamin_farmasi`;
CREATE TABLE IF NOT EXISTS `margin_penjamin_farmasi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PENJAMIN` smallint(6) NOT NULL COMMENT 'Ref = 10',
  `JENIS` tinyint(4) NOT NULL COMMENT 'Ref = 78',
  `MARGIN` decimal(10,2) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `TANGGAL_SK` datetime NOT NULL,
  `NOMOR_SK` varchar(35) NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `CARA_BAYAR` (`PENJAMIN`),
  KEY `JENIS` (`JENIS`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
