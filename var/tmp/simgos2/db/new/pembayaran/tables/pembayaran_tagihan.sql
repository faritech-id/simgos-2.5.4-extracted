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

-- membuang struktur untuk table pembayaran.pembayaran_tagihan
DROP TABLE IF EXISTS `pembayaran_tagihan`;
CREATE TABLE IF NOT EXISTS `pembayaran_tagihan` (
  `TAGIHAN` char(10) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `JENIS` tinyint(4) NOT NULL COMMENT 'Jenis Transaksi Pembayaran Tagihan (REF50)',
  `REF` char(20) NOT NULL COMMENT 'Transaksi Kasir / Ref EDC / Bank',
  `DESKRIPSI` varchar(150) NOT NULL,
  `TOTAL` decimal(60,2) NOT NULL,
  `OLEH` mediumint(9) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`TAGIHAN`,`TANGGAL`,`JENIS`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `JENIS` (`JENIS`),
  KEY `TRANSAKSI_KASIR` (`REF`),
  KEY `TAGIHAN` (`TAGIHAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
