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

-- membuang struktur untuk table kemkes.reservasi_antrian
DROP TABLE IF EXISTS `reservasi_antrian`;
CREATE TABLE IF NOT EXISTS `reservasi_antrian` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PASIEN` int(11) NOT NULL,
  `NAMA` varchar(75) DEFAULT NULL,
  `TEMPAT_LAHIR` varchar(35) DEFAULT NULL,
  `TANGGAL_LAHIR` datetime DEFAULT NULL,
  `KONTAK` varchar(50) DEFAULT NULL,
  `JENIS` tinyint(4) NOT NULL DEFAULT '2' COMMENT '1=Pasien Baru; 2=Pasien Lama',
  `TANGGAL_DAFTAR` datetime DEFAULT NULL,
  `TANGGAL_KUNJUNGAN` date NOT NULL,
  `RUANGAN` char(10) NOT NULL,
  `DOKTER` char(10) DEFAULT NULL,
  `PENJAMIN` smallint(6) DEFAULT NULL,
  `NOMOR` smallint(6) NOT NULL,
  `JAM` time NOT NULL DEFAULT '07:30:00',
  `DIBUAT_TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `PASIEN` (`PASIEN`),
  KEY `RUANGAN` (`RUANGAN`),
  KEY `TANGGAL_KUNJUNGAN` (`TANGGAL_KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
