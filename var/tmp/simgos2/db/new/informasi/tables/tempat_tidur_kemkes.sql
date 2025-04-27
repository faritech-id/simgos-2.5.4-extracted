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

-- membuang struktur untuk table informasi.tempat_tidur_kemkes
DROP TABLE IF EXISTS `tempat_tidur_kemkes`;
CREATE TABLE IF NOT EXISTS `tempat_tidur_kemkes` (
  `IDINSTALASI` varchar(5) NOT NULL,
  `INSTALASI` varchar(200) DEFAULT NULL,
  `IDUNIT` varchar(7) NOT NULL,
  `UNIT` varchar(200) DEFAULT NULL,
  `IDSUBUNIT` varchar(9) NOT NULL,
  `SUBUNIT` varchar(200) DEFAULT NULL,
  `IDKAMAR` varchar(6) NOT NULL,
  `KAMAR` varchar(200) NOT NULL,
  `IDKELAS` varchar(6) NOT NULL,
  `KELAS` varchar(100) NOT NULL,
  `JENISKAMAR` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0=Kosong, 1=Laki-laki, 2=Perempuan',
  `TTLAKI` int(11) NOT NULL DEFAULT '0',
  `TTPEREMPUAN` int(11) NOT NULL DEFAULT '0',
  `JMLLAKI` int(11) NOT NULL DEFAULT '0',
  `JMLPEREMPUAN` int(11) NOT NULL DEFAULT '0',
  `LASTUPDATED` datetime DEFAULT NULL,
  PRIMARY KEY (`IDINSTALASI`,`IDUNIT`,`IDSUBUNIT`,`IDKAMAR`,`IDKELAS`),
  KEY `JENISKAMAR` (`JENISKAMAR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
