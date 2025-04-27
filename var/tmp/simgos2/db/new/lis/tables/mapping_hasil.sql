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

-- membuang struktur untuk table lis.mapping_hasil
DROP TABLE IF EXISTS `mapping_hasil`;
CREATE TABLE IF NOT EXISTS `mapping_hasil` (
  `ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `VENDOR_LIS` tinyint(4) NOT NULL,
  `LIS_KODE_TEST` varchar(50) NOT NULL,
  `HIS_KODE_TEST` int(11) NOT NULL,
  `PARAMETER_TINDAKAN_LAB` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `VENDOR_LIS` (`VENDOR_LIS`),
  KEY `LIS_KODE_TEST` (`LIS_KODE_TEST`),
  KEY `PARAMETER_TINDAKAN_LAB` (`PARAMETER_TINDAKAN_LAB`),
  KEY `HIS_KODE_TES` (`HIS_KODE_TEST`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
