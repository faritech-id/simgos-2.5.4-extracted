-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `kemkes`;

-- membuang struktur untuk table kemkes.pasien
CREATE TABLE IF NOT EXISTS `pasien` (
  `nomr` int(11) NOT NULL,
  `noc` char(25) NOT NULL DEFAULT '',
  `initial` varchar(15) NOT NULL,
  `nama_lengkap` varchar(75) NOT NULL,
  `tglmasuk` date NOT NULL,
  `gender` tinyint(4) NOT NULL,
  `birthdate` date NOT NULL,
  `kewarganegaraan` smallint(6) NOT NULL,
  `sumber_penularan` tinyint(4) NOT NULL DEFAULT '0',
  `kecamatan` char(25) NOT NULL,
  `tglkeluar` date DEFAULT NULL,
  `status_keluar` tinyint(4) NOT NULL DEFAULT '0',
  `tgl_lapor` datetime DEFAULT NULL,
  `status_rawat` tinyint(4) DEFAULT NULL,
  `status_isolasi` tinyint(4) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `notelp` varchar(19) DEFAULT NULL,
  `sebab_kematian` varchar(500) DEFAULT NULL,
  `jenis_pasien` tinyint(4) NOT NULL DEFAULT '1',
  `baru` tinyint(4) NOT NULL DEFAULT '1',
  `hapus` tinyint(4) NOT NULL DEFAULT '0',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint(4) NOT NULL DEFAULT '1',
  `response` varchar(500) DEFAULT NULL,
  `dibuat_oleh` smallint(6) NOT NULL,
  `tgl_dibuat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `diubah_oleh` smallint(6) NOT NULL,
  `tgl_diubah` datetime NOT NULL,
  PRIMARY KEY (`nomr`),
  KEY `kirim` (`kirim`),
  KEY `noc` (`noc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pasien yang teridentifikasi ODP, PDP dan Covid';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
