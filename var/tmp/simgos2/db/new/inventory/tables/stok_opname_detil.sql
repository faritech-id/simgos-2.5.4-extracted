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

-- membuang struktur untuk table inventory.stok_opname_detil
DROP TABLE IF EXISTS `stok_opname_detil`;
CREATE TABLE IF NOT EXISTS `stok_opname_detil` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `STOK_OPNAME` int(10) NOT NULL,
  `BARANG_RUANGAN` int(11) NOT NULL,
  `AWAL` decimal(60,2) NOT NULL COMMENT 'Stok Awal / Stok opname terakhir',
  `SISTEM` decimal(60,2) DEFAULT NULL COMMENT 'Stok Di Sistem',
  `MANUAL` decimal(60,0) DEFAULT NULL COMMENT 'Stok Manual',
  `BARANG_MASUK` decimal(60,2) DEFAULT NULL,
  `BARANG_KELUAR` decimal(60,2) DEFAULT NULL,
  `TANGGAL` date DEFAULT NULL COMMENT 'Posisi Tanggal Pengambilan Stok Akhir',
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `BARANG_RUANGAN` (`BARANG_RUANGAN`),
  KEY `TANGGAL_STOK_AKHIR` (`TANGGAL`),
  KEY `STOK_OPNAME` (`STOK_OPNAME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
