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

-- membuang struktur untuk table inventory.penerimaan_barang_detil
DROP TABLE IF EXISTS `penerimaan_barang_detil`;
CREATE TABLE IF NOT EXISTS `penerimaan_barang_detil` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `PENERIMAAN` int(11) unsigned NOT NULL,
  `BARANG` smallint(6) NOT NULL,
  `NO_BATCH` varchar(50) NOT NULL,
  `JUMLAH` decimal(60,2) NOT NULL,
  `HARGA` decimal(60,2) NOT NULL,
  `DISKON` decimal(10,2) NOT NULL,
  `MASA_BERLAKU` date NOT NULL COMMENT 'Tanggal Berakhir / Expire',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `PENERIMAAN` (`PENERIMAAN`),
  KEY `BARANG` (`BARANG`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
