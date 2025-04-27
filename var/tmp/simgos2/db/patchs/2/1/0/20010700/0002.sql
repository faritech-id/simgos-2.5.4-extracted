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


USE `bpjs`;

-- membuang struktur untuk table bpjs.tempat_tidur
CREATE TABLE IF NOT EXISTS `tempat_tidur` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `kodekelas` char(3) NOT NULL,
  `koderuang` smallint(6) NOT NULL,
  `namaruang` varchar(100) NOT NULL,
  `kapasitas` smallint(6) NOT NULL DEFAULT '0',
  `tersedia` smallint(6) NOT NULL DEFAULT '0',
  `tersediapria` smallint(6) NOT NULL DEFAULT '0',
  `tersediawanita` smallint(6) NOT NULL DEFAULT '0',
  `tersediapriawanita` smallint(6) NOT NULL DEFAULT '0',
  `tanggal_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ruang_baru` tinyint(4) NOT NULL DEFAULT '1',
  `hapus_ruang` tinyint(4) NOT NULL DEFAULT '0',
  `kirim` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `kodekelas_koderuang` (`kodekelas`,`koderuang`),
  KEY `ruang_baru` (`ruang_baru`),
  KEY `kirim` (`kirim`),
  KEY `hapus_ruang` (`hapus_ruang`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
