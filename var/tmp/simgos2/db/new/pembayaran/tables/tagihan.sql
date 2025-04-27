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

-- membuang struktur untuk table pembayaran.tagihan
DROP TABLE IF EXISTS `tagihan`;
CREATE TABLE IF NOT EXISTS `tagihan` (
  `ID` char(10) NOT NULL,
  `REF` int(10) NOT NULL COMMENT 'Pasien / Perusahaan',
  `TANGGAL` datetime NOT NULL,
  `JENIS` tinyint(4) NOT NULL COMMENT 'Jenis Tagihan (REF49)',
  `TOTAL` decimal(60,2) NOT NULL DEFAULT '0.00',
  `PROSEDUR_NON_BEDAH` decimal(60,2) NOT NULL DEFAULT '0.00',
  `PROSEDUR_BEDAH` decimal(60,2) NOT NULL DEFAULT '0.00',
  `KONSULTASI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `TENAGA_AHLI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `KEPERAWATAN` decimal(60,2) NOT NULL DEFAULT '0.00',
  `PENUNJANG` decimal(60,2) NOT NULL DEFAULT '0.00',
  `RADIOLOGI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `LABORATORIUM` decimal(60,2) NOT NULL DEFAULT '0.00',
  `BANK_DARAH` decimal(60,2) NOT NULL DEFAULT '0.00',
  `REHAB_MEDIK` decimal(60,2) NOT NULL DEFAULT '0.00',
  `AKOMODASI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `AKOMODASI_INTENSIF` decimal(60,2) NOT NULL DEFAULT '0.00',
  `OBAT` decimal(60,2) NOT NULL DEFAULT '0.00',
  `OBAT_KRONIS` decimal(60,2) NOT NULL DEFAULT '0.00',
  `OBAT_KEMOTERAPI` decimal(60,2) NOT NULL DEFAULT '0.00',
  `ALKES` decimal(60,2) NOT NULL DEFAULT '0.00',
  `BMHP` decimal(60,2) NOT NULL DEFAULT '0.00',
  `SEWA_ALAT` decimal(60,2) NOT NULL DEFAULT '0.00',
  `RAWAT_INTENSIF` tinyint(4) NOT NULL DEFAULT '0',
  `LAMA_RAWAT_INTENSIF` smallint(6) NOT NULL DEFAULT '0',
  `LAMA_PENGGUNAAN_VENTILATOR` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Dalam Jam',
  `OLEH` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Auto/Sistem',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `NORM` (`REF`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `JENIS` (`JENIS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
