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

-- membuang struktur untuk table inventory.barang
DROP TABLE IF EXISTS `barang`;
CREATE TABLE IF NOT EXISTS `barang` (
  `ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `NAMA` varchar(150) NOT NULL,
  `KATEGORI` char(10) DEFAULT NULL,
  `SATUAN` tinyint(4) NOT NULL,
  `MERK` int(11) DEFAULT NULL COMMENT 'Referensi 39',
  `PENYEDIA` smallint(6) DEFAULT NULL,
  `GENERIK` smallint(6) DEFAULT NULL COMMENT 'Referensi 42',
  `JENIS_GENERIK` int(1) DEFAULT NULL COMMENT '1 : GENERIK, 2 : NON GENERIK',
  `FORMULARIUM` int(1) DEFAULT NULL COMMENT '1 : FORMULARIUM 2: NON FORMULARIUM',
  `STOK` smallint(6) NOT NULL DEFAULT '0',
  `HARGA_BELI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `PPN` decimal(10,2) NOT NULL DEFAULT '0.00',
  `HARGA_JUAL` decimal(10,2) NOT NULL,
  `MASA_BERLAKU` date DEFAULT NULL,
  `JENIS_PENGGUNAAN_OBAT` tinyint(4) DEFAULT NULL,
  `TANGGAL` datetime NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `STATUS` (`STATUS`),
  KEY `NAMA` (`NAMA`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `KATEGORI` (`KATEGORI`),
  KEY `JENIS_PENGGUNAAN_OBAT` (`JENIS_PENGGUNAAN_OBAT`),
  KEY `MASA_BERLAKU` (`MASA_BERLAKU`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
