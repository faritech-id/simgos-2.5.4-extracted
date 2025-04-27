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

-- membuang struktur untuk table kemkes.rujukan
DROP TABLE IF EXISTS `rujukan`;
CREATE TABLE IF NOT EXISTS `rujukan` (
  `NOMOR` char(25) NOT NULL,
  `REF` char(10) NOT NULL,
  `JENIS_RUJUKAN` tinyint(4) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `FASKES_TUJUAN` char(15) NOT NULL,
  `ALASAN` char(2) NOT NULL,
  `ALASAN_LAINNYA` varchar(350) NOT NULL,
  `DIAGNOSA` char(6) NOT NULL,
  `NIK_DOKTER` char(16) NOT NULL,
  `NAMA_DOKTER` varchar(75) NOT NULL,
  `NIK_PETUGAS` char(16) NOT NULL,
  `NAMA_PETUGAS` varchar(75) NOT NULL,
  `NIK_PETUGAS_PEMBATALAN` char(16) DEFAULT NULL,
  `NAMA_PETUGAS_PEMBATALAN` varchar(75) DEFAULT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '0',
  `STATUS_DITERIMA` tinyint(4) DEFAULT NULL,
  `KETERANGAN` text,
  PRIMARY KEY (`NOMOR`),
  UNIQUE KEY `REF` (`REF`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
