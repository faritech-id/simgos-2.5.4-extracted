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

-- membuang struktur untuk table pembayaran.rincian_tagihan_paket
DROP TABLE IF EXISTS `rincian_tagihan_paket`;
CREATE TABLE IF NOT EXISTS `rincian_tagihan_paket` (
  `TAGIHAN` char(10) NOT NULL,
  `PAKET_DETIL` int(4) NOT NULL,
  `REF_ID` char(19) NOT NULL,
  `TARIF_ID` tinyint(4) DEFAULT NULL,
  `JUMLAH` decimal(60,2) NOT NULL DEFAULT '0.00' COMMENT 'Jumlah / Quantity / Volume',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`TAGIHAN`,`PAKET_DETIL`,`REF_ID`),
  KEY `TARIF_ID` (`TARIF_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
