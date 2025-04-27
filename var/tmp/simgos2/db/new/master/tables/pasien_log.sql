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

-- membuang struktur untuk table master.pasien_log
DROP TABLE IF EXISTS `pasien_log`;
CREATE TABLE IF NOT EXISTS `pasien_log` (
  `LOG_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `LOG_TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `NORM` int(11) NOT NULL COMMENT 'Nomor Rekam Medis',
  `NAMA` varchar(75) NOT NULL,
  `PANGGILAN` varchar(15) DEFAULT NULL COMMENT 'Nama Panggilan',
  `GELAR_DEPAN` varchar(25) DEFAULT NULL,
  `GELAR_BELAKANG` varchar(35) DEFAULT NULL,
  `TEMPAT_LAHIR` varchar(35) DEFAULT NULL,
  `TANGGAL_LAHIR` datetime NOT NULL,
  `JENIS_KELAMIN` tinyint(4) NOT NULL DEFAULT '1',
  `ALAMAT` varchar(150) DEFAULT NULL,
  `RT` char(3) DEFAULT NULL,
  `RW` char(3) DEFAULT NULL,
  `KODEPOS` char(5) DEFAULT NULL,
  `WILAYAH` char(10) DEFAULT NULL,
  `AGAMA` tinyint(4) DEFAULT NULL,
  `PENDIDIKAN` tinyint(4) DEFAULT '1',
  `PEKERJAAN` tinyint(4) DEFAULT '1',
  `STATUS_PERKAWINAN` tinyint(4) DEFAULT '1',
  `GOLONGAN_DARAH` tinyint(4) DEFAULT NULL,
  `KEWARGANEGARAAN` smallint(6) NOT NULL DEFAULT '71' COMMENT '71-Indonesia',
  `TANGGAL` datetime NOT NULL COMMENT 'Tanggal Pendaftaran',
  `OLEH` smallint(6) DEFAULT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status Pasien',
  PRIMARY KEY (`LOG_ID`),
  KEY `STATUS` (`STATUS`),
  KEY `NAMA` (`NAMA`),
  KEY `NORM` (`NORM`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
