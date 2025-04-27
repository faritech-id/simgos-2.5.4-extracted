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

-- membuang struktur untuk table pembatalan.pembatalan_retur
DROP TABLE IF EXISTS `pembatalan_retur`;
CREATE TABLE IF NOT EXISTS `pembatalan_retur` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `RETUR` int(11) NOT NULL COMMENT 'retur_farmasi(layanan) / retur penjualan',
  `JENIS` tinyint(4) NOT NULL COMMENT 'Jenis Pembatalan Retur(REF58)',
  `ALASAN` tinyint(4) NOT NULL COMMENT 'Alasan Pembatalan Retur(REF59)',
  `TANGGAL` datetime NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL COMMENT 'Status Pembatalan (1=Dalam Proses; 2=Selesai)',
  PRIMARY KEY (`ID`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `RETUR` (`RETUR`),
  KEY `JENIS` (`JENIS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
