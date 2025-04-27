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

-- membuang struktur untuk table layanan.farmasi
DROP TABLE IF EXISTS `farmasi`;
CREATE TABLE IF NOT EXISTS `farmasi` (
  `ID` char(11) NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `FARMASI` smallint(6) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `JUMLAH` decimal(60,2) NOT NULL,
  `ATURAN_PAKAI` varchar(250) DEFAULT NULL,
  `KETERANGAN` varchar(250) DEFAULT NULL,
  `RACIKAN` tinyint(4) DEFAULT NULL COMMENT 'Referensi Jenis Resep',
  `GROUP_RACIKAN` tinyint(4) DEFAULT '0',
  `PETUNJUK_RACIKAN` varchar(250) DEFAULT NULL,
  `JUMLAH_RACIKAN` DECIMAL(10,0) NULL DEFAULT '0' COMMENT 'Jumlah',
  `ALASAN_TIDAK_TERLAYANI` varchar(250) DEFAULT NULL,
  `HARI` tinyint(4) DEFAULT NULL COMMENT 'Jumlah Hari',
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT '3=Ganti Farmasi',
  `REF` char(11) DEFAULT NULL COMMENT 'ID GANTI FARMASI',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `FARMASI` (`FARMASI`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `STATUS` (`STATUS`),
  KEY `REF` (`REF`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
