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

-- membuang struktur untuk table master.ppk
DROP TABLE IF EXISTS `ppk`;
CREATE TABLE IF NOT EXISTS `ppk` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KODE` char(10) DEFAULT NULL COMMENT 'Kode Kemenkes',
  `BPJS` char(8) DEFAULT NULL COMMENT 'Kode BPJS',
  `JENIS` tinyint(4) DEFAULT NULL COMMENT 'Jenis PPK',
  `KEPEMILIKAN` tinyint(4) DEFAULT NULL COMMENT 'Kepemilikan',
  `JPK` tinyint(4) DEFAULT NULL COMMENT 'Tipe / Jenis Pelayanan Kesehatan',
  `NAMA` varchar(75) NOT NULL,
  `KELAS` char(1) NOT NULL,
  `ALAMAT` varchar(150) NOT NULL,
  `RT` char(3) DEFAULT NULL,
  `RW` char(3) DEFAULT NULL,
  `KODEPOS` char(5) DEFAULT NULL,
  `TELEPON` char(25) DEFAULT NULL,
  `FAX` char(25) NOT NULL,
  `WILAYAH` char(10) DEFAULT NULL,
  `DESWILAYAH` text NOT NULL,
  `MULAI` datetime DEFAULT NULL,
  `BERAKHIR` datetime DEFAULT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `STATUS` (`STATUS`),
  KEY `KODE` (`KODE`),
  KEY `BPJS` (`BPJS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pemberi Pelayanan Kesehatan';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
