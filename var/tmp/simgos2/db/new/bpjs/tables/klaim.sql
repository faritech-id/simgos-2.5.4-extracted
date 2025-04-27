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

-- membuang struktur untuk table bpjs.klaim
DROP TABLE IF EXISTS `klaim`;
CREATE TABLE IF NOT EXISTS `klaim` (
  `noSEP` char(25) NOT NULL,
  `noFPK` char(25) NOT NULL,
  `peserta_noKartu` char(25) NOT NULL,
  `peserta_nama` varchar(100) NOT NULL,
  `peserta_noMR` char(25) NOT NULL,
  `kelasRawat` tinyint(4) NOT NULL,
  `poli` varchar(35) NOT NULL,
  `tglSep` date NOT NULL,
  `tglPulang` date NOT NULL,
  `inacbg_kode` char(15) NOT NULL,
  `inacbg_nama` varchar(150) NOT NULL,
  `biaya_byPengajuan` decimal(60,2) NOT NULL DEFAULT '0.00',
  `biaya_bySetujui` decimal(60,2) NOT NULL DEFAULT '0.00',
  `biaya_byTarifGruper` decimal(60,2) NOT NULL DEFAULT '0.00',
  `biaya_byTarifRS` decimal(60,2) NOT NULL DEFAULT '0.00',
  `biaya_byTopup` decimal(60,2) NOT NULL DEFAULT '0.00',
  `status` varchar(50) NOT NULL,
  `jenisPelayanan` tinyint(4) NOT NULL DEFAULT '1',
  `status_id` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`noSEP`),
  KEY `peserta_noKartu` (`peserta_noKartu`),
  KEY `tglSep` (`tglSep`),
  KEY `tglPulang` (`tglPulang`),
  KEY `status_id` (`status_id`),
  KEY `jenisPelayanan` (`jenisPelayanan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
