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

-- membuang struktur untuk table layanan.kelahiran
DROP TABLE IF EXISTS `kelahiran`;
CREATE TABLE IF NOT EXISTS `kelahiran` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NOPEN` char(10) NOT NULL COMMENT 'No. Pendaftaran Ibu',
  `KUNJUNGAN` char(19) NOT NULL COMMENT 'Kunjungan Ruangan Terakhir',
  `NAMA` varchar(75) NOT NULL COMMENT 'Nama Bayi',
  `JENIS_KELAMIN` tinyint(4) DEFAULT NULL,
  `TANGGAL` datetime NOT NULL COMMENT 'Tanggal & Jam Kelahiran',
  `BERAT` mediumint(9) NOT NULL COMMENT 'Berat Bayi',
  `PANJANG` mediumint(9) NOT NULL COMMENT 'Panjang Badan Bayi',
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `NAMA` (`NAMA`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `NOPEN_IBU` (`NOPEN`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
