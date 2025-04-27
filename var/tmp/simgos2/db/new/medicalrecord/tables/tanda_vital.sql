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

-- membuang struktur untuk table medicalrecord.tanda_vital
DROP TABLE IF EXISTS `tanda_vital`;
CREATE TABLE IF NOT EXISTS `tanda_vital` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `KEADAAN_UMUM` text NOT NULL,
  `KESADARAN` text NOT NULL,
  `SISTOLIK` decimal(10,2) NOT NULL COMMENT 'TEKANAN DARAH : y',
  `DISTOLIK` decimal(10,2) NOT NULL COMMENT 'TEKANAN DARAH : x',
  `FREKUENSI_NADI` decimal(10,2) NOT NULL,
  `FREKUENSI_NAFAS` decimal(10,2) NOT NULL,
  `SUHU` decimal(10,2) NOT NULL,
  `WAKTU_PEMERIKSAAN` datetime NOT NULL COMMENT 'WAKTU PEMERIKSAAN TANDA VITAL PASIEN',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int(11) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `OLEH` (`OLEH`),
  KEY `STATUS` (`STATUS`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT COMMENT='Pemeriksaan->Umum:';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
