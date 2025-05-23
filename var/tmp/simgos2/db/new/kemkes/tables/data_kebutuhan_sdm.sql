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

-- membuang struktur untuk table kemkes.data_kebutuhan_sdm
DROP TABLE IF EXISTS `data_kebutuhan_sdm`;
CREATE TABLE IF NOT EXISTS `data_kebutuhan_sdm` (
  `id_kebutuhan` tinyint(4) NOT NULL,
  `jumlah_eksisting` smallint(6) NOT NULL DEFAULT '0',
  `jumlah` smallint(6) NOT NULL DEFAULT '0',
  `jumlah_diterima` smallint(6) NOT NULL DEFAULT '0',
  `baru` tinyint(4) NOT NULL DEFAULT '1',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint(4) NOT NULL DEFAULT '1',
  `response` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_kebutuhan`),
  KEY `kirim` (`kirim`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
