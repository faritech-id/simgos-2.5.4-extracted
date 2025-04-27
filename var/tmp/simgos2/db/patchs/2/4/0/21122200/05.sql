-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk table bpjs.prb
CREATE TABLE IF NOT EXISTS `prb` (
  `noSRB` char(10) NOT NULL,
  `noKartu` char(19) NOT NULL COMMENT 'noSEP atau noKartu',
  `tglSRB` date DEFAULT NULL,
  `alamat` varchar(250) DEFAULT NULL,
  `email` char(5) DEFAULT NULL,
  `programPRB` char(2) DEFAULT NULL,
  `kodeDPJP` char(10) DEFAULT NULL,
  `keterangan` varchar(250) DEFAULT NULL,
  `saran` varchar(250) DEFAULT NULL,
  `obat` json DEFAULT NULL,
  `user` varchar(75) NOT NULL DEFAULT '',
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`noSRB`) USING BTREE,
  KEY `noKartu` (`noKartu`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
