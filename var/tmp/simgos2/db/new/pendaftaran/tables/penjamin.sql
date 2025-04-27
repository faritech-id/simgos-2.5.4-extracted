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

-- membuang struktur untuk table pendaftaran.penjamin
DROP TABLE IF EXISTS `penjamin`;
CREATE TABLE IF NOT EXISTS `penjamin` (
  `JENIS` smallint(4) NOT NULL COMMENT 'Jenis Kartu Asuransi',
  `NOPEN` char(10) NOT NULL,
  `NOMOR` varchar(25) DEFAULT NULL,
  `KELAS` tinyint(4) DEFAULT NULL COMMENT '1 Kelas 3 2 Kelas 2 3 Kelas 1',
  `JENIS_PESERTA` TINYINT(4) NULL DEFAULT '0',
  `COB` tinyint(4) NOT NULL DEFAULT '0',
  `KATARAK` tinyint(4) NOT NULL DEFAULT '0',
  `NO_SURAT` char(35) NOT NULL,
  `DPJP` char(10) NOT NULL,
  `CATATAN` varchar(250) NOT NULL DEFAULT '-',
  PRIMARY KEY (`JENIS`,`NOPEN`),
  KEY `NOMOR` (`NOMOR`),
  KEY `KELAS` (`KELAS`),
  KEY `NOPEN` (`NOPEN`),
  KEY `JENIS_PESERTA` (`JENIS_PESERTA`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Penjamin & Kelayakan Pasien / Surat Jaminan Pasien (Eligibilitas)';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
