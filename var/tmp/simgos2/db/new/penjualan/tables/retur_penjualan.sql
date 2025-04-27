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

-- membuang struktur untuk table penjualan.retur_penjualan
DROP TABLE IF EXISTS `retur_penjualan`;
CREATE TABLE IF NOT EXISTS `retur_penjualan` (
  `ID` char(10) NOT NULL,
  `PENJUALAN_ID` char(10) DEFAULT NULL,
  `PENJUALAN_DETIL_ID` int(11) DEFAULT NULL,
  `BARANG` smallint(6) DEFAULT NULL,
  `JUMLAH` decimal(10,2) DEFAULT NULL,
  `TANGGAL` datetime DEFAULT NULL,
  `OLEH` smallint(6) DEFAULT NULL,
  `STATUS` tinyint(4) DEFAULT '1' COMMENT '1 = Retur, 0 = Batal Retur',
  PRIMARY KEY (`ID`),
  KEY `BARANG` (`BARANG`),
  KEY `PENJUALAN_ID` (`PENJUALAN_ID`),
  KEY `PENJUALAN_DETIL_ID` (`PENJUALAN_DETIL_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
