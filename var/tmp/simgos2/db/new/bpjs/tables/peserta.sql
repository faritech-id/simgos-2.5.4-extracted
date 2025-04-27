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

-- membuang struktur untuk table bpjs.peserta
DROP TABLE IF EXISTS `peserta`;
CREATE TABLE IF NOT EXISTS `peserta` (
  `noKartu` char(25) NOT NULL,
  `nik` char(16) DEFAULT NULL,
  `norm` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `pisa` varchar(2) DEFAULT NULL,
  `sex` enum('L','P') DEFAULT NULL,
  `tglLahir` datetime DEFAULT NULL,
  `tglCetakKartu` datetime DEFAULT NULL,
  `kdProvider` char(10) DEFAULT NULL COMMENT 'provUmum',
  `nmProvider` varchar(100) DEFAULT NULL,
  `kdCabang` char(10) DEFAULT NULL COMMENT 'Cabang',
  `nmCabang` varchar(100) DEFAULT NULL,
  `kdJenisPeserta` char(2) DEFAULT NULL COMMENT 'jenisPeserta',
  `nmJenisPeserta` varchar(50) DEFAULT NULL,
  `kdKelas` char(5) DEFAULT NULL COMMENT 'kelasTanggungan',
  `nmKelas` varchar(25) DEFAULT NULL,
  `tglTAT` date DEFAULT NULL,
  `tglTMT` date DEFAULT NULL,
  `umurSaatPelayanan` varchar(100) DEFAULT NULL,
  `umurSekarang` varchar(100) DEFAULT NULL,
  `dinsos` varchar(100) DEFAULT NULL,
  `iuran` varchar(100) DEFAULT NULL,
  `noSKTM` varchar(100) DEFAULT NULL,
  `prolanisPRB` varchar(100) DEFAULT NULL,
  `kdStatusPeserta` char(2) DEFAULT NULL,
  `ketStatusPeserta` varchar(150) DEFAULT NULL,
  `noTelepon` varchar(70) DEFAULT NULL,
  `noAsuransi` char(25) DEFAULT NULL COMMENT 'cob',
  `nmAsuransi` varchar(100) DEFAULT NULL,
  `cobTglTAT` date DEFAULT NULL,
  `cobTglTMT` date DEFAULT NULL,
  `tanggal` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`noKartu`),
  KEY `nik` (`nik`),
  KEY `norm` (`norm`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
