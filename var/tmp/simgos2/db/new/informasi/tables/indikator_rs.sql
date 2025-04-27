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

-- membuang struktur untuk table informasi.indikator_rs
DROP TABLE IF EXISTS `indikator_rs`;
CREATE TABLE IF NOT EXISTS `indikator_rs` (
  `TANGGAL` date NOT NULL DEFAULT '0000-00-00',
  `AWAL` int(11) NOT NULL DEFAULT '0',
  `MASUK` int(11) NOT NULL DEFAULT '0',
  `PINDAHAN` int(11) NOT NULL DEFAULT '0',
  `KURANG48JAM` int(11) NOT NULL DEFAULT '0',
  `LEBIH48JAM` int(11) NOT NULL DEFAULT '0',
  `LD` int(11) NOT NULL DEFAULT '0',
  `SISA` int(11) NOT NULL DEFAULT '0',
  `TTIDUR` int(11) NOT NULL DEFAULT '0',
  `HP` int(11) NOT NULL DEFAULT '0',
  `DIPINDAHKAN` int(11) NOT NULL DEFAULT '0',
  `JMLKLR` int(11) NOT NULL DEFAULT '0',
  `JMLHARI` int(11) NOT NULL DEFAULT '0',
  `LASTUPDATED` datetime DEFAULT NULL,
  PRIMARY KEY (`TANGGAL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
