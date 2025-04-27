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

-- membuang struktur untuk table bpjs.rujukan
DROP TABLE IF EXISTS `rujukan`;
CREATE TABLE IF NOT EXISTS `rujukan` (
  `noRujukan` char(25) NOT NULL,
  `noSep` char(25) NOT NULL,
  `tglRujukan` date NOT NULL,
  `ppkDirujuk` char(10) NOT NULL,
  `jnsPelayanan` tinyint(4) NOT NULL DEFAULT '2',
  `catatan` varchar(250) NOT NULL,
  `diagRujukan` varchar(10) NOT NULL,
  `tipeRujukan` tinyint(4) NOT NULL DEFAULT '0',
  `poliRujukan` char(10) NOT NULL,
  `user` varchar(150) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`noRujukan`),
  KEY `tglRujukan` (`tglRujukan`),
  KEY `noSep` (`noSep`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
