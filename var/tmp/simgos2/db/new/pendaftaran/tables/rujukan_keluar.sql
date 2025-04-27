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

-- membuang struktur untuk table pendaftaran.rujukan_keluar
DROP TABLE IF EXISTS `rujukan_keluar`;
CREATE TABLE IF NOT EXISTS `rujukan_keluar` (
  `NOMOR` char(10) NOT NULL,
  `NOPEN` char(10) NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `JENIS` tinyint(4) NOT NULL COMMENT 'REF (86)',
  `TANGGAL` datetime NOT NULL,
  `TUJUAN` int(11) NOT NULL COMMENT 'PPK (ID)',
  `TUJUAN_RUANGAN` smallint(6) NOT NULL COMMENT 'REF70',
  `DIAGNOSA` char(6) NOT NULL,
  `DOKTER` smallint(6) NOT NULL,
  `KETERANGAN` varchar(250) NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`NOMOR`),
  KEY `JENIS` (`JENIS`),
  KEY `NOPEN` (`NOPEN`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `TUJUAN` (`TUJUAN`),
  KEY `TUJUAN_RUANGAN` (`TUJUAN_RUANGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
