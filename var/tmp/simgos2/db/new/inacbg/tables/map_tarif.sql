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

-- membuang struktur untuk table inacbg.map_tarif
DROP TABLE IF EXISTS `map_tarif`;
CREATE TABLE IF NOT EXISTS `map_tarif` (
  `KELASRS` char(10) NOT NULL COMMENT 'Kelas RS ',
  `KEPEMILIKAN` char(10) NOT NULL COMMENT 'Jenis Kepemilikan, Pemerintah atau Swasta',
  `TIPE` tinyint(4) NOT NULL COMMENT 'Tipe Inacbg',
  `JENISTARIF` char(10) NOT NULL COMMENT 'JenisTarif INACBG, JENIS=10',
  PRIMARY KEY (`KELASRS`,`KEPEMILIKAN`,`TIPE`),
  KEY `JENISTARIF` (`JENISTARIF`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
