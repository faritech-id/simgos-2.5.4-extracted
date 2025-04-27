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

-- membuang struktur untuk table master.jenis_berkas_rm
DROP TABLE IF EXISTS `jenis_berkas_rm`;
CREATE TABLE IF NOT EXISTS `jenis_berkas_rm` (
  `JENIS` tinyint(4) NOT NULL COMMENT '1=Rawat Jalan, 2=Rawat Darurat, 3=Rawat Inap',
  `ID` tinyint(4) NOT NULL AUTO_INCREMENT,
  `DESKRIPSI` varchar(35) NOT NULL,
  `KODE` char(25) NOT NULL,
  PRIMARY KEY (`JENIS`,`ID`),
  KEY `KODE` (`KODE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
