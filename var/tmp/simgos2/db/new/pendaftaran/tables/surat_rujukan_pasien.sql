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

-- membuang struktur untuk table pendaftaran.surat_rujukan_pasien
DROP TABLE IF EXISTS `surat_rujukan_pasien`;
CREATE TABLE IF NOT EXISTS `surat_rujukan_pasien` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PPK` int(11) NOT NULL,
  `NORM` int(11) NOT NULL,
  `NOMOR` varchar(35) NOT NULL,
  `TANGGAL` datetime DEFAULT NULL,
  `DOKTER` varchar(75) DEFAULT NULL,
  `BAGIAN_DOKTER` varchar(100) DEFAULT NULL,
  `DIAGNOSA_MASUK` int(6) DEFAULT NULL COMMENT 'Diagnosa Masuk',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status Rujukan',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PPK_NORM_NOMOR` (`PPK`,`NORM`,`NOMOR`),
  KEY `DIAGNOSA_MASUK` (`DIAGNOSA_MASUK`),
  KEY `NORM` (`NORM`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `STATUS` (`STATUS`),
  KEY `PPK` (`PPK`),
  KEY `NOMOR` (`NOMOR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
