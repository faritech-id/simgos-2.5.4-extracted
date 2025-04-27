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

-- membuang struktur untuk table inventory.penerimaan_barang
DROP TABLE IF EXISTS `penerimaan_barang`;
CREATE TABLE IF NOT EXISTS `penerimaan_barang` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RUANGAN` char(10) NOT NULL,
  `FAKTUR` varchar(50) NOT NULL,
  `TANGGAL` datetime NOT NULL COMMENT 'Tanggal Faktur',
  `TANGGAL_PENERIMAAN` datetime NULL COMMENT 'Tanggal Penerimaan Barang',
  `REKANAN` smallint(6) NOT NULL,
  `KETERANGAN` varchar(250) NOT NULL,
  `PPN` enum('Ya','Tidak') NOT NULL,
  `MASA_BERLAKU` date NOT NULL,
  `TANGGAL_DIBUAT` datetime NOT NULL COMMENT 'Tanggal di input',
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `FAKTUR` (`FAKTUR`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `REKANAN` (`REKANAN`),
  KEY `RUANGAN` (`RUANGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
