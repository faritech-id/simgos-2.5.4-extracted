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

-- membuang struktur untuk table inventory.transaksi_stok_ruangan
DROP TABLE IF EXISTS `transaksi_stok_ruangan`;
CREATE TABLE IF NOT EXISTS `transaksi_stok_ruangan` (
  `ID` char(23) NOT NULL,
  `BARANG_RUANGAN` int(11) NOT NULL,
  `JENIS` tinyint(4) NOT NULL COMMENT 'Jenis Transaksi Stok',
  `REF` char(25) NOT NULL COMMENT 'Ref Transaksi',
  `TANGGAL` datetime NOT NULL,
  `JUMLAH` decimal(60,2) NOT NULL,
  `STOK` decimal(60,2) NOT NULL COMMENT 'Stok Akhir / Saldo',
  `FLAG` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'flag(jgn di ubah manual)',
  PRIMARY KEY (`ID`),
  KEY `BARANG_RUANGAN` (`BARANG_RUANGAN`),
  KEY `JENIS` (`JENIS`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `REF` (`REF`),
  CONSTRAINT `FK_JENIS_TRANSAKSI_STOK_TSR` FOREIGN KEY (`JENIS`) REFERENCES `jenis_transaksi_stok` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
