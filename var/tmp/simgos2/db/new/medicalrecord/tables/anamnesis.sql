-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.26 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk table medicalrecord.anamnesis
DROP TABLE IF EXISTS `anamnesis`;
CREATE TABLE IF NOT EXISTS `anamnesis` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `PENDAFTARAN` char(10) NOT NULL COMMENT 'NOPEN',
  `DESKRIPSI` text NOT NULL COMMENT 'Anamnesis Deskripsi',
  `RPP` text NOT NULL COMMENT 'Riwayat Perjalanan Penyakit (depricated)',
  `KELUHAN_UTAMA` text COMMENT ' (depricated)',
  `RPS` text COMMENT 'Riwayat Penyakit Sekarang  (depricated)',
  `RPT` text COMMENT 'Riwayat Penyakit Terdahulu  (depricated)',
  `RPK` text COMMENT 'Riwayat Penyakit Keluarga  (depricated)',
  `RL` text COMMENT 'Riwayat Lainnya  (depricated)',
  `RIWAYAT_ALERGI` text,
  `REAKSI_ALERGI` text,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN_PENDAFTARAN` (`KUNJUNGAN`,`PENDAFTARAN`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `PENDAFTARAN` (`PENDAFTARAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
