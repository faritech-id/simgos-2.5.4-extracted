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

-- membuang struktur untuk table pendaftaran.mutasi
DROP TABLE IF EXISTS `mutasi`;
CREATE TABLE IF NOT EXISTS `mutasi` (
  `NOMOR` char(21) NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `TUJUAN` char(10) NOT NULL,
  `RESERVASI` char(10) DEFAULT NULL,
  `IKUT_IBU` tinyint(19) NOT NULL DEFAULT '0' COMMENT '0=Tdk; 1=Ya',
  `KUNJUNGAN_IBU` char(19) DEFAULT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL COMMENT 'Status Ambil Pasien',
  PRIMARY KEY (`NOMOR`),
  KEY `TUJUAN` (`TUJUAN`),
  KEY `RESERVASI` (`RESERVASI`),
  KEY `STATUS` (`STATUS`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `IKUT_IBU` (`IKUT_IBU`),
  KEY `KUNJUNGAN_IBU` (`KUNJUNGAN_IBU`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
