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

-- membuang struktur untuk table pegawai.kartu_identitas
DROP TABLE IF EXISTS `kartu_identitas`;
CREATE TABLE IF NOT EXISTS `kartu_identitas` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint(4) NOT NULL COMMENT 'REF(9)',
  `NIP` varchar(30) NOT NULL,
  `NOMOR` varchar(16) NOT NULL,
  `ALAMAT` varchar(150) NOT NULL,
  `RT` char(3) DEFAULT NULL,
  `RW` char(3) DEFAULT NULL,
  `KODEPOS` char(5) DEFAULT NULL,
  `WILAYAH` char(10) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `JENIS_NIP_NOMOR` (`JENIS`,`NIP`,`NOMOR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='KIP';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
