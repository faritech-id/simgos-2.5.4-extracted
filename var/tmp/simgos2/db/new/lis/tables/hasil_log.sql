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

-- membuang struktur untuk table lis.hasil_log
DROP TABLE IF EXISTS `hasil_log`;
CREATE TABLE IF NOT EXISTS `hasil_log` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `LIS_NO` char(10) NOT NULL,
  `HIS_NO_LAB` char(23) NOT NULL COMMENT 'layanan.kunjungan.NOMOR',
  `LIS_KODE_TEST` varchar(50) NOT NULL,
  `LIS_NAMA_TEST` varchar(150) NOT NULL,
  `LIS_HASIL` varchar(500) NOT NULL,
  `LIS_CATATAN` varchar(500) DEFAULT NULL,
  `LIS_NILAI_NORMAL` varchar(500) DEFAULT NULL,
  `LIS_FLAG` char(5) DEFAULT NULL,
  `LIS_SATUAN` varchar(25) DEFAULT NULL,
  `LIS_NAMA_INSTRUMENT` varchar(50) DEFAULT NULL,
  `LIS_TANGGAL` datetime DEFAULT NULL,
  `LIS_USER` varchar(50) DEFAULT NULL,
  `HIS_KODE_TEST` int(11) NOT NULL,
  `REF` varchar(50) DEFAULT NULL,
  `VENDOR_LIS` tinyint(4) NOT NULL,
  `LIS_LOKASI` varchar(50) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `HIS_NO_LAB` (`HIS_NO_LAB`),
  KEY `LIS_KODE_TEST` (`LIS_KODE_TEST`),
  KEY `VENDOR_LIS` (`VENDOR_LIS`),
  KEY `LIS_NO` (`LIS_NO`),
  KEY `LIS_NAMA_TEST` (`LIS_NAMA_TEST`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
