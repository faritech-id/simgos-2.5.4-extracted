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

-- membuang struktur untuk table master.kartu_asuransi_pasien
DROP TABLE IF EXISTS `kartu_asuransi_pasien`;
CREATE TABLE IF NOT EXISTS `kartu_asuransi_pasien` (
  `JENIS` smallint(4) NOT NULL,
  `NORM` int(11) NOT NULL,
  `NOMOR` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`JENIS`,`NORM`),
  KEY `NORM` (`NORM`),
  KEY `NOMOR` (`NOMOR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='KAP';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
