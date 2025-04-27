-- --------------------------------------------------------
-- Host:                         192.168.23.237
-- Versi server:                 5.7.30 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `medicalrecord`;

-- membuang struktur untuk table medicalrecord.rencana_terapi
CREATE TABLE IF NOT EXISTS `rencana_terapi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) DEFAULT NULL,
  `DESKRIPSI` text,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint(6) DEFAULT NULL,
  `STATUS` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Perencanaan:';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
