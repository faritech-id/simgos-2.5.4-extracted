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

-- membuang struktur untuk table master.keluarga_pasien
DROP TABLE IF EXISTS `keluarga_pasien`;
CREATE TABLE IF NOT EXISTS `keluarga_pasien` (
  `SHDK` tinyint(4) NOT NULL COMMENT 'Status Hubungan Dalam Keluarga',
  `NORM` int(11) NOT NULL,
  `JENIS_KELAMIN` tinyint(4) NOT NULL DEFAULT '1',
  `ID` smallint(11) NOT NULL,
  `NAMA` varchar(75) NOT NULL,
  `ALAMAT` varchar(150) DEFAULT NULL,
  `PENDIDIKAN` tinyint(4) DEFAULT NULL,
  `PEKERJAAN` tinyint(4) NOT NULL,
  PRIMARY KEY (`SHDK`,`NORM`,`JENIS_KELAMIN`,`ID`),
  KEY `NORM` (`NORM`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
