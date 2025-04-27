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

-- membuang struktur untuk table master.pegawai
DROP TABLE IF EXISTS `pegawai`;
CREATE TABLE IF NOT EXISTS `pegawai` (
  `ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `NIP` varchar(30) NOT NULL COMMENT 'Nomor Induk Pegawai / Karyawan',
  `NAMA` varchar(75) NOT NULL,
  `PANGGILAN` varchar(15) DEFAULT NULL,
  `GELAR_DEPAN` varchar(25) DEFAULT NULL,
  `GELAR_BELAKANG` varchar(35) DEFAULT NULL,
  `TEMPAT_LAHIR` varchar(35) NOT NULL,
  `TANGGAL_LAHIR` datetime DEFAULT NULL,
  `AGAMA` tinyint(4) DEFAULT NULL,
  `JENIS_KELAMIN` tinyint(4) NOT NULL DEFAULT '1',
  `PROFESI` tinyint(4) NOT NULL,
  `SMF` tinyint(4) NOT NULL DEFAULT '36',
  `ALAMAT` varchar(150) NOT NULL,
  `RT` char(3) DEFAULT NULL,
  `RW` char(3) DEFAULT NULL,
  `KODEPOS` char(5) DEFAULT NULL,
  `WILAYAH` char(10) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `NIP` (`NIP`),
  KEY `NAMA` (`NAMA`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pegawai / Karyawan';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
