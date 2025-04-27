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

-- membuang struktur untuk table layanan.order_detil_resep
DROP TABLE IF EXISTS `order_detil_resep`;
CREATE TABLE IF NOT EXISTS `order_detil_resep` (
  `ORDER_ID` char(21) NOT NULL,
  `FARMASI` smallint(6) NOT NULL COMMENT 'barang farmasi',
  `JUMLAH` decimal(60,2) NOT NULL,
  `ATURAN_PAKAI` varchar(250) DEFAULT NULL,
  `KETERANGAN` varchar(250) DEFAULT NULL,
  `RACIKAN` tinyint(4) NOT NULL COMMENT 'referensi Jenis Resep',
  `GROUP_RACIKAN` tinyint(4) NOT NULL DEFAULT '0',
  `PETUNJUK_RACIKAN` varchar(250) DEFAULT NULL,
  `JUMLAH_RACIKAN` decimal(10,0) DEFAULT NULL COMMENT 'Jumlah ',
  `REF` char(11) DEFAULT NULL COMMENT 'layanan farmasi',
  PRIMARY KEY (`ORDER_ID`,`FARMASI`),
  KEY `REF` (`REF`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
