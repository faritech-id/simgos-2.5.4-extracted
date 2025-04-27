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

-- membuang struktur untuk table bpjs.kunjungan
DROP TABLE IF EXISTS `kunjungan`;
CREATE TABLE IF NOT EXISTS `kunjungan` (
  `noKartu` char(25) NOT NULL,
  `noSEP` char(25) NOT NULL,
  `tglSEP` datetime NOT NULL,
  `tglRujukan` datetime DEFAULT NULL,
  `asalRujukan` tinyint(4) DEFAULT NULL,
  `noRujukan` char(25) DEFAULT NULL,
  `ppkRujukan` char(10) DEFAULT NULL,
  `ppkPelayanan` char(10) DEFAULT NULL,
  `jenisPelayanan` tinyint(11) DEFAULT NULL,
  `catatan` varchar(250) DEFAULT NULL,
  `diagAwal` varchar(10) DEFAULT NULL,
  `poliTujuan` char(10) DEFAULT NULL,
  `eksekutif` tinyint(4) DEFAULT '0',
  `klsRawat` tinyint(4) DEFAULT NULL,
  `cob` tinyint(4) DEFAULT '0',
  `katarak` tinyint(4) DEFAULT '0',
  `noSuratSKDP` char(50) DEFAULT NULL,
  `dpjpSKDP` char(7) DEFAULT NULL,
  `lakaLantas` tinyint(4) DEFAULT '2' COMMENT 'Y=1; N=2',
  `penjamin` tinyint(4) DEFAULT '0',
  `tglKejadian` date DEFAULT NULL,
  `suplesi` tinyint(4) DEFAULT '0',
  `noSuplesi` char(25) DEFAULT NULL,
  `lokasiLaka` varchar(150) DEFAULT NULL COMMENT 'keterangan',
  `propinsi` char(2) DEFAULT NULL,
  `kabupaten` char(4) DEFAULT NULL,
  `kecamatan` char(4) DEFAULT NULL,
  `noTelp` varchar(75) DEFAULT '0',
  `user` varchar(150) DEFAULT NULL,
  `cetak` tinyint(4) NOT NULL DEFAULT '0',
  `jmlCetak` tinyint(1) NOT NULL DEFAULT '1',
  `ip` char(15) NOT NULL,
  `noTrans` char(10) DEFAULT NULL,
  `errMsgMapTrx` text,
  `manualUptNoTrans` tinyint(4) NOT NULL DEFAULT '0',
  `tglPlg` datetime DEFAULT NULL,
  `errMsgUptTglPlg` text,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `user_batal` varchar(150) DEFAULT NULL,
  `batalSEP` tinyint(4) DEFAULT '0',
  `errMsgBatalSEP` text,
  PRIMARY KEY (`noKartu`,`noSEP`),
  KEY `tglSEP` (`tglSEP`),
  KEY `noTrans` (`noTrans`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
