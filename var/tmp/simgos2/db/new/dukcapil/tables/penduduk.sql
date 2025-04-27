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

-- membuang struktur untuk table dukcapil.penduduk
DROP TABLE IF EXISTS `penduduk`;
CREATE TABLE IF NOT EXISTS `penduduk` (
  `NIK` char(16) NOT NULL,
  `NO_KK` char(16) NOT NULL,
  `NAMA_LGKP` varchar(120) NOT NULL,
  `JENIS_KLMIN` varchar(22) NOT NULL,
  `TMPT_LHR` varchar(120) NOT NULL,
  `TGL_LHR` date NOT NULL,
  `GOL_DARAH` varchar(22) DEFAULT NULL,
  `AGAMA` varchar(25) DEFAULT NULL,
  `STATUS_KAWIN` varchar(25) NOT NULL,
  `STAT_HBKEL` varchar(30) DEFAULT NULL,
  `PNYDNG_CCT` varchar(25) DEFAULT NULL,
  `PDDK_AKH` varchar(50) DEFAULT NULL,
  `JENIS_PKRJN` varchar(50) DEFAULT NULL,
  `NO_AKTA_LHR` varchar(50) DEFAULT NULL,
  `NAMA_LGKP_IBU` varchar(120) DEFAULT NULL,
  `NAMA_LGKP_AYAH` varchar(120) DEFAULT NULL,
  `EKTP_STATUS` varchar(20) DEFAULT NULL,
  `EKTP_CREATED` date DEFAULT NULL,
  PRIMARY KEY (`NIK`),
  KEY `NO_KK` (`NO_KK`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
