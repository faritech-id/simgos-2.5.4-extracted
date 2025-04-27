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

-- membuang struktur untuk table pembayaran.rincian_tagihan_temp
DROP TABLE IF EXISTS `rincian_tagihan_temp`;
CREATE TABLE IF NOT EXISTS `rincian_tagihan_temp` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `TANGGAL` datetime NOT NULL,
  `TAGIHAN` char(10) NOT NULL,
  `REF_ID` char(19) NOT NULL,
  `JENIS` tinyint(4) NOT NULL COMMENT 'Jenis Tarif (REF30)',
  `TARIF_ID` int(11) DEFAULT NULL COMMENT 'Tabel Tarif',
  `JUMLAH` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Jumlah / Quantity / Volume',
  `TARIF` decimal(60,2) NOT NULL DEFAULT '0.00',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `TANGGAL` (`TANGGAL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Untuk menampung data jika terjadi reStoreTagihan';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
