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

-- membuang struktur untuk table kemkes.diagnosa_pasien
CREATE TABLE IF NOT EXISTS `diagnosa_pasien` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nomr` int(11) NOT NULL,
  `icd` char(10) NOT NULL,
  `level` tinyint(4) NOT NULL,
  `baru` tinyint(4) NOT NULL DEFAULT '1',
  `hapus` tinyint(4) NOT NULL DEFAULT '0',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint(4) NOT NULL DEFAULT '1',
  `response` varchar(500) DEFAULT NULL,
  `dibuat_oleh` smallint(6) NOT NULL,
  `tgl_dibuat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `diubah_oleh` smallint(6) DEFAULT NULL,
  `tgl_diubah` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nomr_icd_level` (`nomr`,`icd`,`level`),
  KEY `kirim` (`kirim`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
