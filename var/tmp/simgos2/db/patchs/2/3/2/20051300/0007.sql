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

USE `inacbg`;

-- membuang struktur untuk table inacbg.dokumen_pendukung
CREATE TABLE IF NOT EXISTS `dokumen_pendukung` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `no_klaim` char(25) NOT NULL COMMENT 'nomor sep',
  `file_id` smallint(6) DEFAULT NULL,
  `file_class` varchar(25) NOT NULL,
  `file_name` varchar(100) NOT NULL,
  `file_size` float NOT NULL COMMENT 'KB',
  `file_type` varchar(50) NOT NULL DEFAULT '0',
  `file_content` mediumblob NOT NULL,
  `kirim_bpjs` tinyint(4) NOT NULL DEFAULT '0',
  `status` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `nopen_file_class` (`no_klaim`,`file_class`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
