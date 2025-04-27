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

-- membuang struktur untuk table penjualan.penjualan_detil
DROP TABLE IF EXISTS `penjualan_detil`;
CREATE TABLE IF NOT EXISTS `penjualan_detil` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PENJUALAN_ID` char(10) NOT NULL,
  `BARANG` smallint(6) NOT NULL COMMENT 'Barang Farmasi',
  `HARGA_BARANG` int(11) DEFAULT NULL,
  `ATURAN_PAKAI` varchar(50) DEFAULT NULL,
  `JUMLAH` decimal(10,2) NOT NULL,
  `MARGIN` int(11) NOT NULL DEFAULT '0' COMMENT 'ID Margin Tuslah',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `PENJUALAN_ID` (`PENJUALAN_ID`),
  KEY `BARANG` (`BARANG`),
  KEY `HARGA_BARANG` (`HARGA_BARANG`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
