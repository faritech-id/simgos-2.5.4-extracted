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

-- membuang struktur untuk table dukcapil.keluarga
DROP TABLE IF EXISTS `keluarga`;
CREATE TABLE IF NOT EXISTS `keluarga` (
  `NO_KK` char(16) NOT NULL,
  `NO_PROP` char(2) NOT NULL,
  `PROP_NAME` varchar(60) NOT NULL,
  `NO_KAB` char(2) NOT NULL,
  `KAB_NAME` varchar(60) NOT NULL,
  `NO_KEC` char(2) NOT NULL,
  `KEC_NAME` varchar(60) NOT NULL,
  `NO_KEL` char(4) NOT NULL,
  `KEL_NAME` varchar(60) NOT NULL,
  `ALAMAT` varchar(240) NOT NULL,
  `NO_RT` char(3) NOT NULL,
  `NO_RW` char(3) NOT NULL,
  `DUSUN` varchar(120) DEFAULT NULL,
  `KODE_POS` char(5) DEFAULT NULL,
  PRIMARY KEY (`NO_KK`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
