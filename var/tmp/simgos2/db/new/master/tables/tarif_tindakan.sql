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

-- membuang struktur untuk table master.tarif_tindakan
DROP TABLE IF EXISTS `tarif_tindakan`;
CREATE TABLE IF NOT EXISTS `tarif_tindakan` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `TINDAKAN` smallint(6) NOT NULL,
  `KELAS` tinyint(4) NOT NULL,
  `ADMINISTRASI` int(11) NOT NULL,
  `SARANA` int(11) NOT NULL,
  `BHP` int(11) NOT NULL,
  `DOKTER_OPERATOR` int(11) NOT NULL,
  `DOKTER_ANASTESI` int(11) NOT NULL,
  `DOKTER_LAINNYA` int(11) NOT NULL,
  `PENATA_ANASTESI` int(11) NOT NULL,
  `PARAMEDIS` int(11) NOT NULL,
  `NON_MEDIS` int(11) NOT NULL,
  `TARIF` int(11) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `TANGGAL_SK` datetime DEFAULT NULL,
  `NOMOR_SK` varchar(35) DEFAULT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `TINDAKAN_KELAS_TANGGAL` (`TINDAKAN`,`KELAS`,`TANGGAL`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `KELAS` (`KELAS`),
  KEY `TINDAKAN` (`TINDAKAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
