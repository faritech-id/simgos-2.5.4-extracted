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

-- membuang struktur untuk table inventory.rumus_perencanaan
DROP TABLE IF EXISTS `rumus_perencanaan`;
CREATE TABLE IF NOT EXISTS `rumus_perencanaan` (
  `ID_RUMUS` int(11) NOT NULL AUTO_INCREMENT,
  `KATEGORI` char(1) NOT NULL COMMENT 'A/B/C',
  `PERIODE_PERENCANAAN` int(11) NOT NULL COMMENT 'PERIODE PERENCANAAN (1/2/3/4 DALAM SATUAN MINGGU)',
  `VOLUME_PRESENTASE` int(11) NOT NULL COMMENT 'VOLUME ( SATUAN % )',
  `LEAD_TIME` int(1) NOT NULL COMMENT 'JANGKA WAKTU PENERIMAAN BARANG SETELAH ORDER',
  `STATUS` int(1) NOT NULL DEFAULT '1',
  `OLEH` int(10) NOT NULL,
  `UPDATE_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID_RUMUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
