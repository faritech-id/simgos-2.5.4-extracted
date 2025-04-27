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

-- Membuang struktur basisdata untuk inacbg
USE `inacbg`;

-- membuang struktur untuk table inacbg.icd_ina_grouper
CREATE TABLE IF NOT EXISTS `icd_ina_grouper` (
  `code` char(15) NOT NULL,
  `description` varchar(250) NOT NULL,
  `validcode` char(1) NOT NULL DEFAULT '' COMMENT '1=Bisa di pilih',
  `accpdx` char(1) NOT NULL DEFAULT '' COMMENT 'Y=Bisa jadi diagnosa utama (utk diagnosa)',
  `code_asterisk` char(15) NOT NULL DEFAULT '' COMMENT ' (utk diagnosa)',
  `asterisk` char(1) NOT NULL DEFAULT '' COMMENT ' (utk diagnosa)',
  `im` char(1) NOT NULL DEFAULT '' COMMENT 'Indonesian Modification',
  `icd_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1=Diagnosa; 2=Prosedur',
  PRIMARY KEY (`code`),
  KEY `description` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
