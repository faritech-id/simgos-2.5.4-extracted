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

-- membuang struktur untuk table pendaftaran.tujuan_pasien
DROP TABLE IF EXISTS `tujuan_pasien`;
CREATE TABLE IF NOT EXISTS `tujuan_pasien` (
  `NOPEN` char(10) NOT NULL,
  `RUANGAN` char(10) NOT NULL COMMENT 'Optional Jika Rawat Inap',
  `RESERVASI` char(10) DEFAULT NULL,
  `SMF` tinyint(4) NOT NULL,
  `DOKTER` smallint(6) NOT NULL,
  `IKUT_IBU` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0=Tdk; 1 = Ya',
  `KUNJUNGAN_IBU` char(19) DEFAULT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status Ambil Pasien 1 = Belum 2 = Sudah',
  PRIMARY KEY (`NOPEN`),
  KEY `RUANGAN` (`RUANGAN`),
  KEY `RESERVASI` (`RESERVASI`),
  KEY `SMF` (`SMF`),
  KEY `DOKTER` (`DOKTER`),
  KEY `STATUS` (`STATUS`),
  KEY `IKUT_IBU` (`IKUT_IBU`),
  KEY `KUNJUNGAN_IBU` (`KUNJUNGAN_IBU`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
