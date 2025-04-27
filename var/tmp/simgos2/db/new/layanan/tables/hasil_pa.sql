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

-- membuang struktur untuk table layanan.hasil_pa
DROP TABLE IF EXISTS `hasil_pa`;
CREATE TABLE IF NOT EXISTS `hasil_pa` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `JENIS_PEMERIKSAAN` tinyint(4) NOT NULL,
  `LOKASI` varchar(200) DEFAULT NULL,
  `DIDAPAT_DENGAN` varchar(200) DEFAULT NULL,
  `CAIRAN_FIKSASI` varchar(200) DEFAULT NULL,
  `DIAGNOSA_KLINIK` varchar(200) DEFAULT NULL,
  `KETERANGAN_KLINIK` text,
  `MAKROSKOPIK` text,
  `MIKROSKOPIK` text,
  `KESIMPULAN` text,
  `IMUNO_HISTOKIMIA` text,
  `REEVALUASI` text,
  `TANGGAL_IMUNO` datetime DEFAULT NULL,
  `DOKTER` smallint(6) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `JENIS_PEMERIKSAAN` (`JENIS_PEMERIKSAAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
