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

-- membuang struktur untuk table informasi.statistik_indikator
DROP TABLE IF EXISTS `statistik_indikator`;
CREATE TABLE IF NOT EXISTS `statistik_indikator` (
  `TAHUN` smallint(6) NOT NULL,
  `PERIODE` char(3) NOT NULL,
  `JENIS` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1. BULANAN, 2. TRIWULAN, 3. TAHUNAN',
  `REF_ID_KEMKES` char(50) NOT NULL,
  `BOR` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ALOS` decimal(10,2) NOT NULL DEFAULT '0.00',
  `BTO` decimal(10,2) NOT NULL DEFAULT '0.00',
  `TOI` decimal(10,2) NOT NULL DEFAULT '0.00',
  `NDR` decimal(10,2) NOT NULL DEFAULT '0.00',
  `GDR` decimal(10,2) NOT NULL DEFAULT '0.00',
  `TANGGAL_UPDATED` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `KIRIM` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`TAHUN`,`PERIODE`,`JENIS`),
  KEY `REF_ID_KEMKES` (`REF_ID_KEMKES`),
  KEY `TANGGAL_UPDATED` (`TANGGAL_UPDATED`),
  KEY `KIRIM` (`KIRIM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
