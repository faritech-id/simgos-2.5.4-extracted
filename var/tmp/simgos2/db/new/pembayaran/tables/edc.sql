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

-- membuang struktur untuk table pembayaran.edc
DROP TABLE IF EXISTS `edc`;
CREATE TABLE IF NOT EXISTS `edc` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `TAGIHAN` char(10) NOT NULL,
  `BANK` tinyint(4) NOT NULL,
  `JENIS_KARTU` tinyint(4) NOT NULL,
  `NOMOR` char(25) NOT NULL COMMENT 'Nomor Kartu',
  `PEMILIK` varchar(75) NOT NULL,
  `APRV_CODE` varchar(75) NOT NULL,
  `TOTAL` decimal(60,2) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `TAGIHAN_BANK_JENIS_KARTU_NOMOR_APRV_CODE` (`TAGIHAN`,`BANK`,`JENIS_KARTU`,`NOMOR`,`APRV_CODE`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `TAGIHAN` (`TAGIHAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
